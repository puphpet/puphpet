require 'puppet/provider/package'
require 'uri'

# Ruby gems support.
Puppet::Type.type(:rvm_gem).provide(:gem) do
  desc "Ruby Gem support using RVM."

  has_feature :versionable
  has_command(:rvmcmd, '/usr/local/rvm/bin/rvm') do
    environment :HOME => ENV['HOME']
  end


  def ruby_version
    resource[:ruby_version]
  end

  def gembinary
    [command(:rvmcmd), ruby_version, "do", "gem"]
  end


  def gemlist(hash)
    command = gembinary + ['list']

    if hash[:local]
      command << "--local"
    else
      command << "--remote"
    end

    if name = hash[:justme]
      command << '^' + name + '$'
    end

    # use proxy if proxy_url is set
    if resource[:proxy_url] and !resource[:proxy_url].empty?
      command << "--http-proxy" << resource[:proxy_url]
    end

    list = []
    begin
      list = execute(command).split("\n").collect do |set|
        if gemhash = self.class.gemsplit(set)
          gemhash[:provider] = :gem
          gemhash
        else
          nil
        end
      end.compact
    rescue Puppet::ExecutionFailure => detail
    end

    if hash[:justme]
      return list.shift
    else
      return list
    end
  end

  def self.gemsplit(desc)
    case desc
    when /^\*\*\*/, /^\s*$/, /^\s+/; return nil
    when /gem: not found/; return nil
    # when /^(\S+)\s+\((((((\d+[.]?))+)(,\s)*)+)\)/
    when /^(\S+)\s+\((\d+.*)\)/
      name = $1
      version = $2.split(/,\s*/)
      return {
        :name => name,
        :ensure => version
      }
    else
      Puppet.warning "Could not match #{desc}"
      nil
    end
  end


  def install(useversion = true)
    command = gembinary + ['install']
    command << "-v" << resource[:ensure] if (! resource[:ensure].is_a? Symbol) and useversion
    # Dependencies are now installed by default
    # command << "--include-dependencies"

    # use proxy if proxy_url is set
    if resource[:proxy_url] and !resource[:proxy_url].empty?
      command << "--http-proxy" << resource[:proxy_url]
    end

    if source = resource[:source]
      begin
        uri = URI.parse(source)
      rescue => detail
        fail "Invalid source '#{uri}': #{detail}"
      end

      case uri.scheme
      when nil
        # no URI scheme => interpret the source as a local file
        command << source
      when /file/i
        command << uri.path
      when 'puppet'
        # we don't support puppet:// URLs (yet)
        raise Puppet::Error.new("puppet:// URLs are not supported as gem sources")
      else
        # interpret it as a gem repository
        command << "--source" << "#{source}" << resource[:name]
      end
    else
      command << "--no-rdoc" << "--no-ri" <<  resource[:name]
    end

    # makefile opts,
    # must be last
    if resource[:withopts]
      command << "--" << resource[:withopts]
    end

    output = execute(command)
    # Apparently some stupid gem versions don't exit non-0 on failure
    self.fail "Could not install: #{output.chomp}" if output.include?("ERROR")
  end

  def latest
    # This always gets the latest version available.
    hash = gemlist(:justme => resource[:name])

    hash[:ensure][0]
  end

  def query
    gemlist(:justme => resource[:name], :local => true)
  end

  def uninstall
    execute(gembinary + ["uninstall", "-x", "-a", resource[:name]])
  end

  def update
    self.install(false)
  end
end
