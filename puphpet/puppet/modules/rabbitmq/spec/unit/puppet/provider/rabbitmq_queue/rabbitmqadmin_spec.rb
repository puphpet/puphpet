require 'puppet'
require 'mocha/api'
RSpec.configure do |config|
  config.mock_with :mocha
end
provider_class = Puppet::Type.type(:rabbitmq_queue).provider(:rabbitmqadmin)
describe provider_class do
  before :each do
    @resource = Puppet::Type::Rabbitmq_queue.new(
      {:name => 'test@/',
       :durable => :true,
       :auto_delete => :false,
       :arguments => {}
      }
    )
    @provider = provider_class.new(@resource)
  end

  it 'should return instances' do
    provider_class.expects(:rabbitmqctl).with('list_vhosts', '-q').returns <<-EOT
/
EOT
    provider_class.expects(:rabbitmqctl).with('list_queues', '-q', '-p', '/', 'name', 'durable', 'auto_delete', 'arguments').returns <<-EOT
test  true  false []
test2 true  false [{"x-message-ttl",342423},{"x-expires",53253232},{"x-max-length",2332},{"x-max-length-bytes",32563324242},{"x-dead-letter-exchange","amq.direct"},{"x-dead-letter-routing-key","test.routing"}]
EOT
    instances = provider_class.instances
    instances.size.should == 2
  end

  it 'should call rabbitmqadmin to create' do
    @provider.expects(:rabbitmqadmin).with('declare', 'queue', '--vhost=/', '--user=guest', '--password=guest', '-c', '/etc/rabbitmq/rabbitmqadmin.conf', 'name=test', 'durable=true', 'auto_delete=false', 'arguments={}')
    @provider.create
  end

  it 'should call rabbitmqadmin to destroy' do
    @provider.expects(:rabbitmqadmin).with('delete', 'queue', '--vhost=/', '--user=guest', '--password=guest', '-c', '/etc/rabbitmq/rabbitmqadmin.conf', 'name=test')
    @provider.destroy
  end

  context 'specifying credentials' do
    before :each do
      @resource = Puppet::Type::Rabbitmq_queue.new(
        {:name => 'test@/',
        :durable => 'true',
        :auto_delete => 'false',
        :arguments => {},
        :user => 'colin',
        :password => 'secret',
        }
      )
      @provider = provider_class.new(@resource)
    end

    it 'should call rabbitmqadmin to create' do
      @provider.expects(:rabbitmqadmin).with('declare', 'queue', '--vhost=/', '--user=colin', '--password=secret', '-c', '/etc/rabbitmq/rabbitmqadmin.conf', 'name=test', 'durable=true', 'auto_delete=false', 'arguments={}')
      @provider.create
    end
  end
end
