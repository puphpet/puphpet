require 'puppet'
require 'mocha'

RSpec.configure do |config|
  config.mock_with :mocha
end

describe Puppet::Type.type(:rabbitmq_policy).provider(:rabbitmqctl) do

  let(:resource) do
    Puppet::Type.type(:rabbitmq_policy).new(
      :name       => 'ha-all@/',
      :pattern    => '.*',
      :definition => {
        'ha-mode' => 'all'
      },
      :provider => described_class.name
    )
  end

  let(:provider) { resource.provider }

  after(:each) do
    described_class.instance_variable_set(:@policies, nil)
  end

  it 'should accept @ in policy name' do
    resource = Puppet::Type.type(:rabbitmq_policy).new(
      :name       => 'ha@home@/',
      :pattern    => '.*',
      :definition => {
        'ha-mode' => 'all'
      },
      :provider => described_class.name
    )
    provider = described_class.new(resource)
    provider.should_policy.should == 'ha@home'
    provider.should_vhost.should == '/'
  end

  it 'should fail with invalid output from list' do
    provider.class.expects(:rabbitmqctl).with('list_policies', '-q', '-p', '/').returns 'foobar'
    expect { provider.exists? }.to raise_error(Puppet::Error, /cannot parse line from list_policies/)
  end

  it 'should match policies from list (>=3.2.0)' do
    provider.class.expects(:rabbitmqctl).with('list_policies', '-q', '-p', '/').returns <<-EOT
/ ha-all all .* {"ha-mode":"all","ha-sync-mode":"automatic"} 0
/ test exchanges .* {"ha-mode":"all"} 0
EOT
    provider.exists?.should == {
      :applyto    => 'all',
      :pattern    => '.*',
      :priority   => '0',
      :definition => {
        'ha-mode'      => 'all',
        'ha-sync-mode' => 'automatic'}
      }
  end

  it 'should match policies from list (<3.2.0)' do
    provider.class.expects(:rabbitmqctl).with('list_policies', '-q', '-p', '/').returns <<-EOT
/ ha-all .* {"ha-mode":"all","ha-sync-mode":"automatic"} 0
/ test .* {"ha-mode":"all"} 0
EOT
    provider.exists?.should == {
      :applyto    => 'all',
      :pattern    => '.*',
      :priority   => '0',
      :definition => {
        'ha-mode'      => 'all',
        'ha-sync-mode' => 'automatic'}
      }
  end

  it 'should not match an empty list' do
    provider.class.expects(:rabbitmqctl).with('list_policies', '-q', '-p', '/').returns ''
    provider.exists?.should == nil
  end

  it 'should destroy policy' do
    provider.expects(:rabbitmqctl).with('clear_policy', '-p', '/', 'ha-all')
    provider.destroy
  end

  it 'should only call set_policy once (<3.2.0)' do
    provider.class.expects(:rabbitmq_version).returns '3.1.0'
    provider.resource[:priority] = '10'
    provider.resource[:applyto] = 'exchanges'
    provider.expects(:rabbitmqctl).with('set_policy',
      '-p', '/',
      'ha-all',
      '.*',
      '{"ha-mode":"all"}',
      '10').once
    provider.priority = '10'
    provider.applyto = 'exchanges'
  end

  it 'should only call set_policy once (>=3.2.0)' do
    provider.class.expects(:rabbitmq_version).returns '3.2.0'
    provider.resource[:priority] = '10'
    provider.resource[:applyto] = 'exchanges'
    provider.expects(:rabbitmqctl).with('set_policy',
      '-p', '/',
      '--priority', '10',
      '--apply-to', 'exchanges',
      'ha-all',
      '.*',
      '{"ha-mode":"all"}').once
    provider.priority = '10'
    provider.applyto = 'exchanges'
  end
end
