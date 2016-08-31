require 'pathname'

Puppet::Type.newtype(:apt_key) do

  @doc = <<-EOS
    This type provides Puppet with the capabilities to manage GPG keys needed
    by apt to perform package validation. Apt has it's own GPG keyring that can
    be manipulated through the `apt-key` command.

    apt_key { '4BD6EC30':
      source => 'http://apt.puppetlabs.com/pubkey.gpg'
    }

    **Autorequires**:

    If Puppet is given the location of a key file which looks like an absolute
    path this type will autorequire that file.
  EOS

  ensurable

  validate do
    if self[:content] and self[:source]
      fail('The properties content and source are mutually exclusive.')
    end
    if self[:id].length < 40 
      warning('The id should be a full fingerprint (40 characters), see README.')
    end 
  end

  newparam(:id, :namevar => true) do
    desc 'The ID of the key you want to manage.'
    # GPG key ID's should be either 32-bit (short) or 64-bit (long) key ID's
    # and may start with the optional 0x, or they can be 40-digit key fingerprints
    newvalues(/\A(0x)?[0-9a-fA-F]{8}\Z/, /\A(0x)?[0-9a-fA-F]{16}\Z/, /\A(0x)?[0-9a-fA-F]{40}\Z/)
    munge do |value|
      if value.start_with?('0x')
        id = value.partition('0x').last.upcase
      else
        id = value.upcase
      end
      id
    end
  end

  newparam(:content) do
    desc 'The content of, or string representing, a GPG key.'
  end

  newparam(:source) do
    desc 'Location of a GPG key file, /path/to/file, ftp://, http:// or https://'
    newvalues(/\Ahttps?:\/\//, /\Aftp:\/\//, /\A\/\w+/)
  end

  autorequire(:file) do
    if self[:source] and Pathname.new(self[:source]).absolute?
      self[:source]
    end
  end

  newparam(:server) do
    desc 'The key server to fetch the key from based on the ID. It can either be a domain name or url.'
    defaultto :'keyserver.ubuntu.com'
    
    newvalues(/\A((hkp|http|https):\/\/)?([a-z\d])([a-z\d-]{0,61}\.)+[a-z\d]+(:\d{2,5})?$/)
  end

  newparam(:keyserver_options) do
    desc 'Additional options to pass to apt-key\'s --keyserver-options.'
  end

  newproperty(:fingerprint) do
    desc <<-EOS
      The 40-digit hexadecimal fingerprint of the specified GPG key.

      This property is read-only.
    EOS
  end

  newproperty(:long) do
    desc <<-EOS
      The 16-digit hexadecimal id of the specified GPG key.

      This property is read-only.
    EOS
  end

  newproperty(:short) do
    desc <<-EOS
      The 8-digit hexadecimal id of the specified GPG key.

      This property is read-only.
    EOS
  end

  newproperty(:expired) do
    desc <<-EOS
      Indicates if the key has expired.

      This property is read-only.
    EOS
  end

  newproperty(:expiry) do
    desc <<-EOS
      The date the key will expire, or nil if it has no expiry date.

      This property is read-only.
    EOS
  end

  newproperty(:size) do
    desc <<-EOS
      The key size, usually a multiple of 1024.

      This property is read-only.
    EOS
  end

  newproperty(:type) do
    desc <<-EOS
      The key type, one of: rsa, dsa, ecc, ecdsa

      This property is read-only.
    EOS
  end

  newproperty(:created) do
    desc <<-EOS
      Date the key was created.

      This property is read-only.
    EOS
  end
end
