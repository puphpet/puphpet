require 'spec_helper_acceptance'

describe 'rabbitmq binding:' do


  context "create binding and queue resources when rabbit using default management port" do
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

      rabbitmq_user { 'dan':
        admin    => true,
        password => 'bar',
        tags     => ['monitoring', 'tag1'],
      } ->
      
      rabbitmq_user_permissions { 'dan@host1':
        configure_permission => '.*',
        read_permission      => '.*',
        write_permission     => '.*',
      }

      rabbitmq_vhost { 'host1':
        ensure => present,
      } ->

      rabbitmq_exchange { 'exchange1@host1':
        user     => 'dan',
        password => 'bar',
        type     => 'topic',
        ensure   => present,
      } ->

      rabbitmq_queue { 'queue1@host1':
        user        => 'dan',
        password    => 'bar',
        durable     => true,
        auto_delete => false,
        ensure      => present,
      } ->

      rabbitmq_binding { 'exchange1@queue1@host1':
        user             => 'dan',
        password         => 'bar',
        destination_type => 'queue',
        routing_key      => '#',
        ensure           => present,
      }
      
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have the binding' do
      shell('rabbitmqctl list_bindings -q -p host1') do |r|
        expect(r.stdout).to match(/exchange1\sexchange\squeue1\squeue\s#/)
        expect(r.exit_code).to be_zero
      end
    end
    
    it 'should have the queue' do
      shell('rabbitmqctl list_queues -q -p host1') do |r|
        expect(r.stdout).to match(/queue1/)
        expect(r.exit_code).to be_zero
      end
    end

  end
  
  context "create binding and queue resources when rabbit using a non-default management port" do
    it 'should run successfully' do
      pp = <<-EOS
      if $::osfamily == 'RedHat' {
        class { 'erlang': epel_enable => true }
        Class['erlang'] -> Class['::rabbitmq']
      }
      class { '::rabbitmq':
        service_manage    => true,
        port              => '5672',
        management_port   => '11111',
        delete_guest_user => true,
        admin_enable      => true,
      } ->

      rabbitmq_user { 'dan':
        admin    => true,
        password => 'bar',
        tags     => ['monitoring', 'tag1'],
      } ->
      
      rabbitmq_user_permissions { 'dan@host2':
        configure_permission => '.*',
        read_permission      => '.*',
        write_permission     => '.*',
      }

      rabbitmq_vhost { 'host2':
        ensure => present,
      } ->

      rabbitmq_exchange { 'exchange2@host2':
        user     => 'dan',
        password => 'bar',
        type     => 'topic',
        ensure   => present,
      } ->

      rabbitmq_queue { 'queue2@host2':
        user        => 'dan',
        password    => 'bar',
        durable     => true,
        auto_delete => false,
        ensure      => present,
      } ->

      rabbitmq_binding { 'exchange2@queue2@host2':
        user             => 'dan',
        password         => 'bar',
        destination_type => 'queue',
        routing_key      => '#',
        ensure           => present,
      }
     
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have the binding' do
      shell('rabbitmqctl list_bindings -q -p host2') do |r|
        expect(r.stdout).to match(/exchange2\sexchange\squeue2\squeue\s#/)
        expect(r.exit_code).to be_zero
      end
    end
    
    it 'should have the queue' do
      shell('rabbitmqctl list_queues -q -p host2') do |r|
        expect(r.stdout).to match(/queue2/)
        expect(r.exit_code).to be_zero
      end
    end

  end
  
end
