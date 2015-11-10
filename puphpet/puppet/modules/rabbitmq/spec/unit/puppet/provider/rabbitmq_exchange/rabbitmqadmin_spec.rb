require 'puppet'
require 'mocha'
RSpec.configure do |config|
  config.mock_with :mocha
end
provider_class = Puppet::Type.type(:rabbitmq_exchange).provider(:rabbitmqadmin)
describe provider_class do
  before :each do
    @resource = Puppet::Type::Rabbitmq_exchange.new(
      {:name => 'test.headers@/',
       :type => :headers,
       :internal => :false,
       :durable => :true,
       :auto_delete => :false,
       :arguments => {
        "hash-headers" => "message-distribution-hash" 
        },
      }
    )
    @provider = provider_class.new(@resource)
  end

  it 'should return instances' do
    provider_class.expects(:rabbitmqctl).with('-q', 'list_vhosts').returns <<-EOT
/
EOT
    provider_class.expects(:rabbitmqctl).with('-q', 'list_exchanges', '-p', '/', 'name', 'type', 'internal', 'durable', 'auto_delete', 'arguments').returns <<-EOT
        direct  false   true    false   []
amq.direct      direct  false   true    false   []
amq.fanout      fanout  false   true    false   []
amq.headers     headers false   true    false   []
amq.match       headers false   true    false   []
amq.rabbitmq.log        topic   true    true    false   []
amq.rabbitmq.trace      topic   true    true    false   []
amq.topic       topic   false   true    false   []
test.headers    x-consistent-hash       false   true    false   [{"hash-header","message-distribution-hash"}]
EOT
    instances = provider_class.instances
    instances.size.should == 9
  end

  it 'should call rabbitmqadmin to create as guest' do
    @provider.expects(:rabbitmqadmin).with('declare', 'exchange', '--vhost=/', '--user=guest', '--password=guest', 'name=test.headers', 'type=headers', 'internal=false', 'durable=true', 'auto_delete=false', 'arguments={"hash-headers":"message-distribution-hash"}', '-c', '/etc/rabbitmq/rabbitmqadmin.conf')
    @provider.create
  end

  it 'should call rabbitmqadmin to destroy' do
    @provider.expects(:rabbitmqadmin).with('delete', 'exchange', '--vhost=/', '--user=guest', '--password=guest', 'name=test.headers', '-c', '/etc/rabbitmq/rabbitmqadmin.conf')
    @provider.destroy
  end

  context 'specifying credentials' do
    before :each do
      @resource = Puppet::Type::Rabbitmq_exchange.new(
        {:name => 'test.headers@/',
        :type => :headers,
        :internal => 'false',
        :durable => 'true',
        :auto_delete => 'false',
        :user => 'colin',
        :password => 'secret',
        :arguments => {
          "hash-header" => "message-distribution-hash"
        },
      }
      )
      @provider = provider_class.new(@resource)
    end

    it 'should call rabbitmqadmin to create with credentials' do
      @provider.expects(:rabbitmqadmin).with('declare', 'exchange', '--vhost=/', '--user=colin', '--password=secret', 'name=test.headers', 'type=headers', 'internal=false', 'durable=true', 'auto_delete=false', 'arguments={"hash-header":"message-distribution-hash"}', '-c', '/etc/rabbitmq/rabbitmqadmin.conf')
      @provider.create
    end
  end
end
