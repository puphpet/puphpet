require 'open-uri'
require 'net/ftp'
require 'tempfile'

if RUBY_VERSION == '1.8.7'
  # Mothers cry, puppies die and Ruby 1.8.7's open-uri needs to be
  # monkeypatched to support passing in :ftp_passive_mode.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                    'puppet_x', 'apt_key', 'patch_openuri.rb'))
  OpenURI::Options.merge!({:ftp_active_mode => false,})
end

Puppet::Type.type(:apt_key).provide(:apt_key) do

  confine    :osfamily => :debian
  defaultfor :osfamily => :debian
  commands   :apt_key  => 'apt-key'
  commands   :gpg      => '/usr/bin/gpg'

  def self.instances
    cli_args = ['adv','--list-keys', '--with-colons', '--fingerprint', '--fixed-list-mode']

    if RUBY_VERSION > '1.8.7'
      key_output = apt_key(cli_args).encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '')
    else
      key_output = apt_key(cli_args)
    end

    pub_line, fpr_line = nil

    key_array = key_output.split("\n").collect do |line|
      if line.start_with?('pub')
          pub_line = line
      elsif line.start_with?('fpr')
          fpr_line = line
      end

      next unless (pub_line and fpr_line)

      line_hash = key_line_hash(pub_line, fpr_line)

      # reset everything
      pub_line, fpr_line = nil

      expired = false

      if line_hash[:key_expiry]
        expired = Time.now >= line_hash[:key_expiry]
      end

      new(
        :name        => line_hash[:key_fingerprint],
        :id          => line_hash[:key_long],
        :fingerprint => line_hash[:key_fingerprint],
        :short       => line_hash[:key_short],
        :long        => line_hash[:key_long],
        :ensure      => :present,
        :expired     => expired,
        :expiry      => line_hash[:key_expiry].nil? ? nil : line_hash[:key_expiry].strftime("%Y-%m-%d"),
        :size        => line_hash[:key_size],
        :type        => line_hash[:key_type],
        :created     => line_hash[:key_created].strftime("%Y-%m-%d")
      )
    end
    key_array.compact!
  end

  def self.prefetch(resources)
    apt_keys = instances
    resources.keys.each do |name|
      if name.length == 40
        if provider = apt_keys.find{ |key| key.fingerprint == name }
          resources[name].provider = provider
        end
      elsif name.length == 16
        if provider = apt_keys.find{ |key| key.long == name }
          resources[name].provider = provider
        end
      elsif name.length == 8
        if provider = apt_keys.find{ |key| key.short == name }
          resources[name].provider = provider
        end
      end
    end
  end

  def self.key_line_hash(pub_line, fpr_line)
    pub_split = pub_line.split(':')
    fpr_split = fpr_line.split(':')

    fingerprint = fpr_split.last
    return_hash = {
      :key_fingerprint => fingerprint,
      :key_long        => fingerprint[-16..-1], # last 16 characters of fingerprint
      :key_short       => fingerprint[-8..-1], # last 8 characters of fingerprint
      :key_size        => pub_split[2],
      :key_type        => nil,
      :key_created     => Time.at(pub_split[5].to_i),
      :key_expiry      => pub_split[6].empty? ? nil : Time.at(pub_split[6].to_i),
    }

    # set key type based on types defined in /usr/share/doc/gnupg/DETAILS.gz
    case pub_split[3]
    when "1"
      return_hash[:key_type] = :rsa
    when "17"
      return_hash[:key_type] = :dsa
    when "18"
      return_hash[:key_type] = :ecc
    when "19"
      return_hash[:key_type] = :ecdsa
    end

    return return_hash
  end

  def source_to_file(value)
    parsedValue = URI::parse(value)
    if parsedValue.scheme.nil?
      fail("The file #{value} does not exist") unless File.exists?(value)
      value
    else
      begin
        key = parsedValue.read
      rescue OpenURI::HTTPError, Net::FTPPermError => e
        fail("#{e.message} for #{resource[:source]}")
      rescue SocketError
        fail("could not resolve #{resource[:source]}")
      else
        tempfile(key)
      end
    end
  end

  def tempfile(content)
    file = Tempfile.new('apt_key')
    file.write content
    file.close
    #confirm that the fingerprint from the file, matches the long key that is in the manifest
    if name.size == 40
      if File.executable? command(:gpg)
        extracted_key = execute(["#{command(:gpg)} --with-fingerprint --with-colons #{file.path} | awk -F: '/^fpr:/ { print $10 }'"], :failonfail => false)
        extracted_key = extracted_key.chomp
        if extracted_key != name
          fail("The id in your manifest #{resource[:name]} and the fingerprint from content/source do not match. Please check there is not an error in the id or check the content/source is legitimate.")
        end
      else
        warning('/usr/bin/gpg cannot be found for verification of the id.')
      end
    end
    file.path
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    command = []
    if resource[:source].nil? and resource[:content].nil?
      # Breaking up the command like this is needed because it blows up
      # if --recv-keys isn't the last argument.
      command.push('adv', '--keyserver', resource[:server])
      unless resource[:keyserver_options].nil?
        command.push('--keyserver-options', resource[:keyserver_options])
      end
      command.push('--recv-keys', resource[:id])
    elsif resource[:content]
      command.push('add', tempfile(resource[:content]))
    elsif resource[:source]
      command.push('add', source_to_file(resource[:source]))
    # In case we really screwed up, better safe than sorry.
    else
      fail("an unexpected condition occurred while trying to add the key: #{resource[:id]}")
    end
    apt_key(command)
    @property_hash[:ensure] = :present
  end

  def destroy
    begin
      apt_key('del', resource.provider.short)
      r = execute(["#{command(:apt_key)} list | grep '/#{resource.provider.short}\s'"], :failonfail => false)
    end while r.exitstatus == 0
    @property_hash.clear
  end

  def read_only(value)
    fail('This is a read-only property.')
  end

  mk_resource_methods

  # Needed until PUP-1470 is fixed and we can drop support for Puppet versions
  # before that.
  def expired
    @property_hash[:expired]
  end

  # Alias the setters of read-only properties
  # to the read_only function.
  alias :created= :read_only
  alias :expired= :read_only
  alias :expiry=  :read_only
  alias :size=    :read_only
  alias :type=    :read_only
end
