#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the unique function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("unique")).to eq("function_unique")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_unique([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should remove duplicate elements in a string" do
    result = scope.function_unique(["aabbc"])
    expect(result).to(eq('abc'))
  end

  it "should remove duplicate elements in an array" do
    result = scope.function_unique([["a","a","b","b","c"]])
    expect(result).to(eq(['a','b','c']))
  end

  it "should accept objects which extend String" do
    class AlsoString < String
    end

    value = AlsoString.new('aabbc')
    result = scope.function_unique([value])
    result.should(eq('abc'))
  end
end
