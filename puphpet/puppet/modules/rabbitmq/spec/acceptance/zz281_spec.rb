require 'spec_helper_acceptance'
#
# beacuse of some serious issues with upgrading and downgrading rabbitmq on RedHat,
# we need to run all of the 2.8.1 tests last.
#
# NOTE that this is only tested on RedHat and probably only works there. But I can't seem
# to get 'confine' to work...
#

describe 'rabbitmq class with 2.8.1:' do
  case fact('osfamily')
  when 'RedHat'
    package_name   = 'rabbitmq-server'
    service_name   = 'rabbitmq-server'
    package_source = "http://www.rabbitmq.com/releases/rabbitmq-server/v2.8.1/rabbitmq-server-2.8.1-1.noarch.rpm"
    package_ensure = '2.8.1-1'
  when 'SUSE'
    package_name   = 'rabbitmq-server'
    service_name   = 'rabbitmq-server'
    package_source = "http://www.rabbitmq.com/releases/rabbitmq-server/v2.8.1/rabbitmq-server-2.8.1-1.noarch.rpm"
    package_ensure = '2.8.1-1'
  when 'Debian'
    package_name   = 'rabbitmq-server'
    service_name   = 'rabbitmq-server'
    package_source = ''
    package_ensure = '2.8.1'
  when 'Archlinux'
    package_name   = 'rabbitmq'
    service_name   = 'rabbitmq'
    package_source = ''
    package_ensure = '2.8.1'
  end

  context "default class inclusion" do
    it 'should run successfully' do
      pp = <<-EOS
      class { 'rabbitmq':
        version          => '2.8.1-1',
        package_source   => '#{package_source}',
        package_ensure   => '#{package_ensure}',
        package_provider => 'rpm',
        management_port  => '55672',
      }
      if $::osfamily == 'RedHat' {
        class { 'erlang': epel_enable => true}
        Class['erlang'] -> Class['rabbitmq']
      }
      EOS

      # clean up previous 3.x install - can't be ungraded cleanly via RPM
      shell('service rabbitmq-server stop')
      shell('yum -y erase rabbitmq-server')
      shell('rm -Rf /var/lib/rabbitmq/mnesia /etc/rabbitmq /var/lib/rabbitmq/rabbitmqadmin')
      # Apply twice to ensure no errors the second time.
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_changes => true).exit_code).to be_zero
      # DEBUG
      shell('netstat -lntp')
    end

    describe command('rabbitmqctl status') do
      its(:stdout) { should match /{rabbit,"RabbitMQ","2.8.1"}/ }
    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe service(service_name) do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context "disable and stop service" do
    it 'should run successfully' do
      pp = <<-EOS
      class { 'rabbitmq':
        version          => '2.8.1-1',
        package_source   => '#{package_source}',
        package_ensure   => '#{package_ensure}',
        package_provider => 'rpm',
        management_port  => '55672',
        service_ensure   => 'stopped',
        admin_enable     => false,
      }
      if $::osfamily == 'RedHat' {
        class { 'erlang': epel_enable => true}
        Class['erlang'] -> Class['rabbitmq']
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe service(service_name) do
      it { should_not be_enabled }
      it { should_not be_running }
    end
  end

  context "service is unmanaged" do
    it 'should run successfully' do
      pp_pre = <<-EOS
      class { 'rabbitmq':
        version          => '2.8.1-1',
        package_source   => '#{package_source}',
        package_ensure   => '#{package_ensure}',
        package_provider => 'rpm',
        management_port  => '55672',
      }
      if $::osfamily == 'RedHat' {
        class { 'erlang': epel_enable => true}
        Class['erlang'] -> Class['rabbitmq']
      }
      EOS

      pp = <<-EOS
      class { 'rabbitmq':
        service_manage => false,
        service_ensure  => 'stopped',
      }
      if $::osfamily == 'RedHat' {
        class { 'erlang': epel_enable => true}
        Class['erlang'] -> Class['rabbitmq']
      }
      EOS

      apply_manifest(pp_pre, :catch_failures => true)
      apply_manifest(pp, :catch_failures => true)
    end

    describe service(service_name) do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context 'rabbitmqadmin' do
    #confine :to, :platform => 'el-6-x86'

    it 'should run successfully' do
      pp = <<-EOS
      class { 'rabbitmq':
        admin_enable     => true,
        service_manage   => true,
        version          => '2.8.1-1',
        package_source   => '#{package_source}',
        package_ensure   => '#{package_ensure}',
        package_provider => 'rpm',
        management_port  => '55672',
      }
      if $::osfamily == 'RedHat' {
        class { 'erlang': epel_enable => true}
        Class['erlang'] -> Class['rabbitmq']
      }
      EOS

      shell('rm -f /var/lib/rabbitmq/rabbitmqadmin')
      apply_manifest(pp, :catch_failures => true)
    end

    # since serverspec (used by beaker-rspec) can only tell present/absent for packages
    describe file('/var/lib/rabbitmq/rabbitmqadmin') do
      it { should be_file }
    end
    
    describe command('/usr/local/bin/rabbitmqadmin --help') do
      its(:exit_status) { should eq 0 }
    end

  end

  context 'rabbitmqadmin with specified default credentials' do

    it 'should run successfully' do
      # make sure credential change takes effect before admin_enable
      pp = <<-EOS
      class { 'rabbitmq':
        admin_enable     => true,
        service_manage   => true,
        version          => '2.8.1-1',
        package_source   => '#{package_source}',
        package_ensure   => '#{package_ensure}',
        package_provider => 'rpm',
        management_port  => '55672',
        default_user     => 'foobar',
        default_pass     => 'bazblam',
      }
      if $::osfamily == 'RedHat' {
        class { 'erlang': epel_enable => true}
        Class['erlang'] -> Class['rabbitmq']
      }
      EOS

      # next 3 lines - see MODULES-1085
      shell('service rabbitmq-server stop')
      shell('rm -Rf /var/lib/rabbitmq/mnesia /var/lib/rabbitmq/rabbitmqadmin')
      apply_manifest(pp, :catch_failures => true)
    end

    # since serverspec (used by beaker-rspec) can only tell present/absent for packages
    describe file('/var/lib/rabbitmq/rabbitmqadmin') do
      it { should be_file }
    end

    describe command('/usr/local/bin/rabbitmqadmin --help') do
      its(:exit_status) { should eq 0 }
    end

  end

end
