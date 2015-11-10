require 'puppet'
require 'mocha'
RSpec.configure do |config|
  config.mock_with :mocha
end
provider_class = Puppet::Type.type(:rabbitmq_plugin).provider(:rabbitmqplugins)
describe provider_class do
  before :each do
    @resource = Puppet::Type::Rabbitmq_plugin.new(
      {:name => 'foo'}
    )
    @provider = provider_class.new(@resource)
  end
  it 'should match plugins' do
    @provider.expects(:rabbitmqplugins).with('list', '-E', '-m').returns("foo\n")
    @provider.exists?.should == 'foo'
  end
  it 'should call rabbitmqplugins to enable' do
    @provider.expects(:rabbitmqplugins).with('enable', 'foo')
    @provider.create
  end
  it 'should call rabbitmqplugins to disable' do
    @provider.expects(:rabbitmqplugins).with('disable', 'foo')
    @provider.destroy
  end
end
