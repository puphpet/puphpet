#! /usr/bin/env ruby -S rspec

require 'spec_helper'

if ENV["FUTURE_PARSER"] == 'yes' or Puppet.version >= "4"
  require 'puppet/pops'
  require 'puppet/loaders'

  describe 'the type_of function' do
    before(:all) do
      loaders = Puppet::Pops::Loaders.new(Puppet::Node::Environment.create(:testing, [File.join(fixtures, "modules")]))
      Puppet.push_context({:loaders => loaders}, "test-examples")
    end

    after(:all) do
      Puppet::Pops::Loaders.clear
      Puppet::pop_context()
    end

    let(:func) do
      # Load the function from the environment modulepath's modules (ie, fixtures)
      Puppet.lookup(:loaders).private_environment_loader.load(:function, 'type_of')
    end

    it 'gives the type of a string' do
      expect(func.call({}, 'hello world')).to be_kind_of(Puppet::Pops::Types::PStringType)
    end

    it 'gives the type of an integer' do
      expect(func.call({}, 5)).to be_kind_of(Puppet::Pops::Types::PIntegerType)
    end
  end
end
