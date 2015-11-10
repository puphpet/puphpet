require 'puppet'
require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

# overriding puppet installation for the RedHat family distros due to
# puppet breakage >= 3.5
def install_puppet(host)
  host['platform'] =~ /(fedora|el)-(\d+)/
  if host['platform'] =~ /(fedora|el)-(\d+)/
    safeversion = '3.4.2'
    platform = $1
    relver = $2
    on host, "rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-#{platform}-#{relver}.noarch.rpm"
    on host, "yum install -y puppet-#{safeversion}"
  else
    super()
  end
end

RSpec.configure do |c|

  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.before(:each) do
    Puppet::Util::Log.level = :warning
    Puppet::Util::Log.newdestination(:console)
  end

  c.before :suite do
    hosts.each do |host|
      unless (ENV['RS_PROVISION'] == 'no' || ENV['BEAKER_provision'] == 'no')
        begin
          on host, 'puppet --version'
        rescue
          if host.is_pe?
            install_pe
          else
            install_puppet(host)
          end
        end
      end

      # Install module and dependencies
      puppet_module_install(:source => proj_root, :module_name => File.basename(proj_root).gsub(/^puppet-/,''))

      on host, puppet('module', 'install', 'stahnma-epel', '--version=0.1.0'), { :acceptable_exit_codes => [0,1] } if fact_on(host,'osfamily') == 'RedHat'
      on host, puppet('module', 'install', 'puppetlabs-apache', '--version=1.1.0'), { :acceptable_exit_codes => [0,1] } 
    end
  end

end
