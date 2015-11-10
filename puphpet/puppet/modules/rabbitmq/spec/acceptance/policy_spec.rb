require 'spec_helper_acceptance'

describe 'rabbitmq policy on a vhost:' do


  context "create policy resource" do
    it 'should run successfully' do
      pp = <<-EOS
      if $::osfamily == 'RedHat' {
        class { 'erlang': epel_enable => true }
        Class['erlang'] -> Class['::rabbitmq']
      }
      class { '::rabbitmq':
        service_manage    => true,
        port              => '5672',
        delete_guest_user => true,
        admin_enable      => true,
      } ->

      rabbitmq_vhost { 'myhost':
        ensure => present,
      } ->

      rabbitmq_policy { 'ha-all@myhost':
        pattern    => '.*',
        priority   => 0,
        applyto    => 'all',
        definition => {
          'ha-mode'      => 'all',
          'ha-sync-mode' => 'automatic',
        },
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have the policy' do
      shell('rabbitmqctl list_policies -p myhost') do |r|
        expect(r.stdout).to match(/myhost.*ha-all.*ha-sync-mode/)
        expect(r.exit_code).to be_zero
      end
    end

  end
end
