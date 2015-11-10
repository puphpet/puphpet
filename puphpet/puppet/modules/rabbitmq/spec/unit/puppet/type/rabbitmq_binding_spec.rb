require 'puppet'
require 'puppet/type/rabbitmq_binding'
describe Puppet::Type.type(:rabbitmq_binding) do
  before :each do
    @binding = Puppet::Type.type(:rabbitmq_binding).new(
      :name => 'foo@blub@bar',
      :destination_type => :queue
    )
  end
  it 'should accept an queue name' do
    @binding[:name] = 'dan@dude@pl'
    @binding[:name].should == 'dan@dude@pl'
  end
  it 'should require a name' do
    expect {
      Puppet::Type.type(:rabbitmq_binding).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end
  it 'should not allow whitespace in the name' do
    expect {
      @binding[:name] = 'b r'
    }.to raise_error(Puppet::Error, /Valid values match/)
  end
  it 'should not allow names without one @' do
    expect {
      @binding[:name] = 'b_r'
    }.to raise_error(Puppet::Error, /Valid values match/)
  end

  it 'should not allow names without two @' do
    expect {
      @binding[:name] = 'b@r'
    }.to raise_error(Puppet::Error, /Valid values match/)
  end

  it 'should accept an binding destination_type' do
    @binding[:destination_type] = :exchange
    @binding[:destination_type].should == :exchange
  end

  it 'should accept a user' do
    @binding[:user] = :root
    @binding[:user].should == :root
  end

  it 'should accept a password' do
    @binding[:password] = :PaSsw0rD
    @binding[:password].should == :PaSsw0rD
  end
end
