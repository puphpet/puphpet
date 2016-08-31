require 'beaker-rspec'
require 'pry'

# Install Puppet and PHP
hosts.each do |host|
  on host, install_puppet
  install_package host, options['php_cli_package']
end

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  module_name = 'blackfire'

  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    puppet_module_install(:source => module_root, :module_name => module_name)
    hosts.each do |host|
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => 0 }
      on host, puppet('module','install','puppetlabs-apt'), { :acceptable_exit_codes => 0 }
      on host, puppet('module','install','puppetlabs-inifile'), { :acceptable_exit_codes => 0 }
    end
  end
end
