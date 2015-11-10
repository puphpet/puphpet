require 'beaker-rspec'

unless ENV['RS_PROVISION'] == 'no'
  hosts.each do |host|
    if host.is_pe?
      install_pe
    else
      install_puppet
      on host, "mkdir -p #{host['distmoduledir']}"
    end
  end
end

UNSUPPORTED_PLATFORMS = ['windows']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'swap_file')
    hosts.each do |host|
      shell('/bin/touch /etc/puppet/hiera.yaml')
      shell('puppet module install puppetlabs-stdlib --version 3.2.0', { :acceptable_exit_codes => [0,1] })
    end
  end
end
