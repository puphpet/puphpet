require 'pathname'
require 'fileutils'
require 'puppet/util'

Puppet::Type.type(:pyenv_python).provide(:pyenv) do

  defaultfor :feature => :posix
  confine :feature => :pyenv

  if not Facter.value(:pyenv_binary).nil?
    has_command(:pyenv, Facter.value(:pyenv_binary)) do
      PYENV_ROOT = File.dirname(File.dirname(Pathname.new(Facter.value(:pyenv_binary)).realpath.to_s))
      environment({ 'PYENV_ROOT' => PYENV_ROOT })
    end
  else
    has_command(:pyenv, 'pyenv') do
      WHICH = Puppet::Util.which('pyenv')
      PYENV_ROOT = WHICH ? File.dirname(File.dirname(Pathname.new(WHICH).realpath.to_s)) : '/usr/local/pyenv/'
      environment({ 'PYENV_ROOT' => PYENV_ROOT })
    end
  end

  def self.instances
    python_versions = pyenv('versions').split("\n").collect do |line|
      python_version = parse_line(line)
      next unless python_version

      # Yes Symbols instead of Booleans because we get Symbols from Puppet when
      # we use the virtualenv property. This is madness!
      virtualenv = :false
      if File.exists?("#{PYENV_ROOT}/versions/#{python_version}/bin/virtualenv")
        virtualenv = :true
      end

      # Yes Symbols instead of Booleans because we get Symbols from Puppet when
      # we use the keep property. This is madness!
      keep = :false
      if File.exists?("#{PYENV_ROOT}/sources/#{python_version}")
        keep = :true
      end

      new(
        :name       => python_version,
        :ensure     => :present,
        :virtualenv => virtualenv,
        :keep       => keep
      )
    end
    python_versions.compact!
  end

  def self.prefetch(resources)
    python_versions = instances
    resources.keys.each do |name|
      if provider = python_versions.find{ |key| key.name == name }
        resources[name].provider = provider
      end
    end
  end

  def self.parse_line(line)
    parsed = line.match(/([\w.-]{3,})/).to_a
    # We don't care about the system python so ignore that.
    # If we happen to have a .python-version in the current directory that
    # points to a Python which isn't installed a line with:
    # pyenv: version `whatever' is not installed end up in the output which we
    # want to ignore.
    if parsed[0] == 'system' or parsed[0] == 'pyenv'
      return nil
    else
      return parsed[0]
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    command = ['install']
    # Yes Symbols instead of Booleans because we get Symbols from Puppet when
    # we use the force or resource parameters. This is madness!
    if resource[:keep] == :true
      command.push('--keep')
    end
    if resource[:name].split('-').last == 'debug'
      command.push('--debug')
      command.push(resource[:name].split('-')[0..-1])
    else
      command.push(resource[:name])
    end
    notice("Going to build #{resource[:name]}. This may take some time...")
    pyenv(command)
    @property_hash[:ensure] = :present
    pyenv('rehash')
  end

  def destroy
    # the -f is needed to avoid user input prompt
    pyenv('uninstall', '-f', resource[:name])
    @property_hash.clear
    pyenv('rehash')
  end

  mk_resource_methods

  def virtualenv=(install)
    # Yes Symbols instead of Booleans because we get Symbols from Puppet when
    # we use the virtualenv property. This is madness!
    if install == :true and virtualenv == :false
      command = ["#{PYENV_ROOT}/versions/#{resource[:name]}/bin/pip",
                 'install', '-q', 'virtualenv', '>/dev/null 2>&1']
      `#{command.join(' ')}`
      if $?.success?
        @property_hash[:virtualenv] = :true
      else
        fail('failed to install virtualenv')
      end
      pyenv('rehash')
    elsif install == :false and virtualenv == :true
      command = ["#{PYENV_ROOT}/versions/#{resource[:name]}/bin/pip",
                 'uninstall', '-q', '-y', 'virtualenv', '>/dev/null 2>&1']
      `#{command.join(' ')}`
      if $?.success?
        @property_hash[:virtualenv] = :false
      else
        fail('failed to uninstall virtualenv')
      end
      pyenv('rehash')
    else
      # We can never hit this block as the newvalues on the virtualenv property
      # should prevent us from getting here in the first place. However, this
      # is Puppet so you never know.
      fail('go home puppet, you\'re drunk')
    end
  end

  def keep=(value)
    # Yes Symbols instead of Booleans because we get Symbols from Puppet when
    # we use the keep property. This is madness!
    if not keep and value == :true
      fail('cannot keep source of an already installed Python')
    elsif keep and value == :false
      FileUtils.rm_rf("#{PYENV_ROOT}/sources/#{resource[:name]}")
      @property_hash[:keep] = :false
    else
      # We can never hit this block as the newvalues on the keep property
      # should prevent us from getting here in the first place. However, this
      # is Puppet so you never know.
      fail('go home puppet, you\'re drunk')
    end
  end
end
