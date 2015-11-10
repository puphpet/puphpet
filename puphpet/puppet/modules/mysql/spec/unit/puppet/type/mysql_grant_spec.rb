require 'puppet'
require 'puppet/type/mysql_grant'
describe Puppet::Type.type(:mysql_grant) do

  before :each do
    @user = Puppet::Type.type(:mysql_grant).new(:name => 'foo@localhost/*.*', :privileges => ['ALL', 'PROXY'], :table => ['*.*','@'], :user => 'foo@localhost')
  end

  it 'should accept a grant name' do
    expect(@user[:name]).to eq('foo@localhost/*.*')
  end
  
  it 'should accept ALL privileges' do
    @user[:privileges] = 'ALL'
    expect(@user[:privileges]).to eq(['ALL'])
  end

  it 'should accept PROXY privilege' do
    @user[:privileges] = 'PROXY'
    expect(@user[:privileges]).to eq(['PROXY'])
  end
  
  it 'should accept a table' do
    @user[:table] = '*.*'
    expect(@user[:table]).to eq('*.*')
  end
  
  it 'should accept @ for table' do
    @user[:table] = '@'
    expect(@user[:table]).to eq('@')
  end
  
  it 'should accept a user' do
    @user[:user] = 'foo@localhost'
    expect(@user[:user]).to eq('foo@localhost')
  end
  
  it 'should require a name' do
    expect {
      Puppet::Type.type(:mysql_grant).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should require the name to match the user and table' do
    expect {
      Puppet::Type.type(:mysql_grant).new(:name => 'foo', :privileges => ['ALL', 'PROXY'], :table => ['*.*','@'], :user => 'foo@localhost')
    }.to raise_error /name must match user and table parameters/
  end

  describe 'it should munge privileges' do

    it 'to just ALL' do
      @user = Puppet::Type.type(:mysql_grant).new(
        :name => 'foo@localhost/*.*',  :table => ['*.*','@'], :user => 'foo@localhost',
        :privileges => ['ALL', 'PROXY'] )
      expect(@user[:privileges]).to eq(['ALL'])
    end

    it 'to upcase and ordered' do
      @user = Puppet::Type.type(:mysql_grant).new(
        :name => 'foo@localhost/*.*',  :table => ['*.*','@'], :user => 'foo@localhost',
        :privileges => ['select', 'Insert'] )
      expect(@user[:privileges]).to eq(['INSERT', 'SELECT'])
    end

    it 'ordered including column privileges' do
      @user = Puppet::Type.type(:mysql_grant).new(
        :name => 'foo@localhost/*.*',  :table => ['*.*','@'], :user => 'foo@localhost',
        :privileges => ['SELECT(Host,Address)', 'Insert'] )
      expect(@user[:privileges]).to eq(['INSERT', 'SELECT (Address, Host)'])
    end
  end

end
