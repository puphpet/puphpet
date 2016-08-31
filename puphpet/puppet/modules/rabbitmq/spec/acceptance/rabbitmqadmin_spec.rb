require 'spec_helper_acceptance'

describe 'rabbitmq::install::rabbitmqadmin class' do
  context 'does nothing if service is unmanaged' do
    it 'should run successfully' do
      pp = <<-EOS
      class { 'rabbitmq':
        admin_enable   => true,
        service_manage => false,
      }
      if $::osfamily == 'RedHat' {
        class { 'erlang': epel_enable => true}
        Class['erlang'] -> Class['rabbitmq']
      }
      EOS

      shell('rm -f /var/lib/rabbitmq/rabbitmqadmin')
      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/var/lib/rabbitmq/rabbitmqadmin') do
      it { should_not be_file }
    end
  end

  context 'downloads the cli tools' do
    it 'should run successfully' do
      pp = <<-EOS
      class { 'rabbitmq':
        admin_enable   => true,
        service_manage => true,
      }
      if $::osfamily == 'RedHat' {
        class { 'erlang': epel_enable => true}
        Class['erlang'] -> Class['rabbitmq']
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/var/lib/rabbitmq/rabbitmqadmin') do
      it { should be_file }
    end
  end

  context 'works with specified default credentials' do
    it 'should run successfully' do
      # make sure credential change takes effect before admin_enable
      pp_pre = <<-EOS
      class { 'rabbitmq':
        service_manage => true,
        default_user   => 'foobar',
        default_pass   => 'bazblam',
      }
      if $::osfamily == 'RedHat' {
        class { 'erlang': epel_enable => true}
        Class['erlang'] -> Class['rabbitmq']
      }
      EOS

      pp = <<-EOS
      class { 'rabbitmq':
        admin_enable   => true,
        service_manage => true,
        default_user   => 'foobar',
        default_pass   => 'bazblam',
      }
      if $::osfamily == 'RedHat' {
        class { 'erlang': epel_enable => true}
        Class['erlang'] -> Class['rabbitmq']
      }
      EOS

      shell('rm -f /var/lib/rabbitmq/rabbitmqadmin')
      apply_manifest(pp_pre, :catch_failures => true)
      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/var/lib/rabbitmq/rabbitmqadmin') do
      it { should be_file }
    end
  end

end
