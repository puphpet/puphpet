#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe Puppet::Parser::Functions.function(:merge) do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  describe 'when calling merge from puppet' do
    it "should not compile when no arguments are passed" do
      skip("Fails on 2.6.x, see bug #15912") if Puppet.version =~ /^2\.6\./
      Puppet[:code] = '$x = merge()'
      expect {
        scope.compiler.compile
      }.to raise_error(Puppet::ParseError, /wrong number of arguments/)
    end

    it "should not compile when 1 argument is passed" do
      skip("Fails on 2.6.x, see bug #15912") if Puppet.version =~ /^2\.6\./
      Puppet[:code] = "$my_hash={'one' => 1}\n$x = merge($my_hash)"
      expect {
        scope.compiler.compile
      }.to raise_error(Puppet::ParseError, /wrong number of arguments/)
    end
  end

  describe 'when calling merge on the scope instance' do
    it 'should require all parameters are hashes' do
      expect { new_hash = scope.function_merge([{}, '2'])}.to raise_error(Puppet::ParseError, /unexpected argument type String/)
      expect { new_hash = scope.function_merge([{}, 2])}.to raise_error(Puppet::ParseError, /unexpected argument type Fixnum/)
    end

    it 'should accept empty strings as puppet undef' do
      expect { new_hash = scope.function_merge([{}, ''])}.not_to raise_error
    end

    it 'should be able to merge two hashes' do
      new_hash = scope.function_merge([{'one' => '1', 'two' => '1'}, {'two' => '2', 'three' => '2'}])
      expect(new_hash['one']).to   eq('1')
      expect(new_hash['two']).to   eq('2')
      expect(new_hash['three']).to eq('2')
    end

    it 'should merge multiple hashes' do
      hash = scope.function_merge([{'one' => 1}, {'one' => '2'}, {'one' => '3'}])
      expect(hash['one']).to eq('3')
    end

    it 'should accept empty hashes' do
      expect(scope.function_merge([{},{},{}])).to eq({})
    end
  end
end
