require 'spec_helper'

describe 'the mysql_password function' do
  before :all do
    Puppet::Parser::Functions.autoloader.loadall
  end

  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'should exist' do
    expect(Puppet::Parser::Functions.function('mysql_password')).to eq('function_mysql_password')
  end

  it 'should raise a ParseError if there is less than 1 arguments' do
    expect { scope.function_mysql_password([]) }.to( raise_error(Puppet::ParseError))
  end

  it 'should raise a ParseError if there is more than 1 arguments' do
    expect { scope.function_mysql_password(%w(foo bar)) }.to( raise_error(Puppet::ParseError))
  end

  it 'should convert password into a hash' do
    result = scope.function_mysql_password(%w(password))
    expect(result).to(eq('*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19'))
  end
  
  it 'should convert an empty password into a empty string' do
    result = scope.function_mysql_password([""])
    expect(result).to(eq(''))
  end

end
