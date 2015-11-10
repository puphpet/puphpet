#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the values_at function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("values_at")).to eq("function_values_at")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_values_at([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if you try to use a range where stop is greater then start" do
    expect { scope.function_values_at([['a','b'],["3-1"]]) }.to( raise_error(Puppet::ParseError))
  end

  it "should return a value at from an array" do
    result = scope.function_values_at([['a','b','c'],"1"])
    expect(result).to(eq(['b']))
  end

  it "should return a value at from an array when passed a range" do
    result = scope.function_values_at([['a','b','c'],"0-1"])
    expect(result).to(eq(['a','b']))
  end

  it "should return chosen values from an array when passed number of indexes" do
    result = scope.function_values_at([['a','b','c'],["0","2"]])
    expect(result).to(eq(['a','c']))
  end

  it "should return chosen values from an array when passed ranges and multiple indexes" do
    result = scope.function_values_at([['a','b','c','d','e','f','g'],["0","2","4-5"]])
    expect(result).to(eq(['a','c','e','f']))
  end
end
