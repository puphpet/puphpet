#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the upcase function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("upcase")).to eq("function_upcase")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_upcase([]) }.to(raise_error(Puppet::ParseError))
  end

  it "should upcase a string" do
    result = scope.function_upcase(["abc"])
    expect(result).to(eq('ABC'))
  end

  it "should do nothing if a string is already upcase" do
    result = scope.function_upcase(["ABC"])
    expect(result).to(eq('ABC'))
  end

  it "should accept objects which extend String" do
    class AlsoString < String
    end

    value = AlsoString.new('abc')
    result = scope.function_upcase([value])
    result.should(eq('ABC'))
  end

  it 'should accept hashes and return uppercase' do
    expect(
        scope.function_upcase([{'test' => %w(this that and other thing)}])
    ).to eq({'TEST' => %w(THIS THAT AND OTHER THING)})
  end

  if :test.respond_to?(:upcase)
    it 'should accept hashes of symbols' do
      expect(
          scope.function_upcase([{:test => [:this, :that, :other]}])
      ).to eq({:TEST => [:THIS, :THAT, :OTHER]})
    end
    it 'should return upcase symbol' do
      expect(
          scope.function_upcase([:test])
      ).to eq(:TEST)
    end
    it 'should return mixed objects in upcease' do
      expect(
          scope.function_upcase([[:test, 'woot']])
      ).to eq([:TEST, 'WOOT'])

    end
  end
end
