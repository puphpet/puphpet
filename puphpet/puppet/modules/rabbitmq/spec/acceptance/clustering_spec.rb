require 'spec_helper_acceptance'

describe 'rabbitmq clustering' do
  context 'rabbitmq::wipe_db_on_cookie_change => false' do
    it 'should run successfully' do
      pp = <<-EOS
      class { 'rabbitmq': 
        config_cluster           => true,
        cluster_nodes            => ['rabbit1', 'rabbit2'],
        cluster_node_type        => 'ram',
        erlang_cookie            => 'TESTCOOKIE',
        wipe_db_on_cookie_change => false,
      }
      if $::osfamily == 'RedHat' {
        class { 'erlang': epel_enable => true}
        Class['erlang'] -> Class['rabbitmq']
      }
      EOS

      apply_manifest(pp, :expect_failures => true)
    end

    describe file('/var/lib/rabbitmq/.erlang.cookie') do
      it { should_not contain 'TESTCOOKIE' }
    end

  end
  context 'rabbitmq::wipe_db_on_cookie_change => true' do
    it 'should run successfully' do
      pp = <<-EOS
      class { 'rabbitmq': 
        config_cluster           => true,
        cluster_nodes            => ['rabbit1', 'rabbit2'],
        cluster_node_type        => 'ram',
        erlang_cookie            => 'TESTCOOKIE',
        wipe_db_on_cookie_change => true,
      }
      if $::osfamily == 'RedHat' {
        class { 'erlang': epel_enable => true}
        Class['erlang'] -> Class['rabbitmq']
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/rabbitmq/rabbitmq.config') do
      it { should be_file }
      it { should contain 'cluster_nodes' }
      it { should contain 'rabbit@rabbit1' }
      it { should contain 'rabbit@rabbit2' }
      it { should contain 'ram' }
    end

    describe file('/var/lib/rabbitmq/.erlang.cookie') do
      it { should be_file }
      it { should contain 'TESTCOOKIE' }
    end
  end
end
