require 'puppet'
require 'mocha/api'
RSpec.configure do |config|
  config.mock_with :mocha
end
provider_class = Puppet::Type.type(:rabbitmq_binding).provider(:rabbitmqadmin)
describe provider_class do
  before :each do
    @resource = Puppet::Type::Rabbitmq_binding.new(
      {:name => 'source@target@/',
       :destination_type => :queue,
       :routing_key => 'blablub',
       :arguments => {}
      }
    )
    @provider = provider_class.new(@resource)
  end

  it 'should return instances' do
    provider_class.expects(:rabbitmqctl).with('list_vhosts', '-q').returns <<-EOT
/
EOT
    provider_class.expects(:rabbitmqctl).with('list_bindings', '-q', '-p', '/', 'source_name', 'destination_name', 'destination_kind', 'routing_key', 'arguments').returns <<-EOT
    queue queue queue []
EOT
    instances = provider_class.instances
    instances.size.should == 1
  end
  
  it 'should call rabbitmqadmin to create' do
    @provider.expects(:rabbitmqadmin).with('declare', 'binding', '--vhost=/', '--user=guest', '--password=guest', '-c', '/etc/rabbitmq/rabbitmqadmin.conf', 'source=source', 'destination=target', 'arguments={}', 'routing_key=blablub', 'destination_type=queue')
    @provider.create
  end

  it 'should call rabbitmqadmin to destroy' do
    @provider.expects(:rabbitmqadmin).with('delete', 'binding', '--vhost=/', '--user=guest', '--password=guest', '-c', '/etc/rabbitmq/rabbitmqadmin.conf', 'source=source', 'destination_type=queue', 'destination=target', 'properties_key=blablub')
    @provider.destroy
  end

  context 'specifying credentials' do
    before :each do
      @resource = Puppet::Type::Rabbitmq_binding.new(
        {:name => 'source@test2@/',
         :destination_type => :queue,
         :routing_key => 'blablubd',
         :arguments => {},
         :user => 'colin',
         :password => 'secret'
        }
      )
      @provider = provider_class.new(@resource)
    end

    it 'should call rabbitmqadmin to create' do
      @provider.expects(:rabbitmqadmin).with('declare', 'binding', '--vhost=/', '--user=colin', '--password=secret', '-c', '/etc/rabbitmq/rabbitmqadmin.conf', 'source=source', 'destination=test2', 'arguments={}', 'routing_key=blablubd', 'destination_type=queue')
      @provider.create
    end
  end
end
