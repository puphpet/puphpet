#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the any2array function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("any2array")).to eq("function_any2array")
  end

  it "should return an empty array if there is less than 1 argument" do
    result = scope.function_any2array([])
    expect(result).to(eq([]))
  end

  it "should convert boolean true to [ true ] " do
    result = scope.function_any2array([true])
    expect(result).to(eq([true]))
  end

  it "should convert one object to [object]" do
    result = scope.function_any2array(['one'])
    expect(result).to(eq(['one']))
  end

  it "should convert multiple objects to [objects]" do
    result = scope.function_any2array(['one', 'two'])
    expect(result).to(eq(['one', 'two']))
  end

  it "should return empty array it was called with" do
    result = scope.function_any2array([[]])
    expect(result).to(eq([]))
  end

  it "should return one-member array it was called with" do
    result = scope.function_any2array([['string']])
    expect(result).to(eq(['string']))
  end

  it "should return multi-member array it was called with" do
    result = scope.function_any2array([['one', 'two']])
    expect(result).to(eq(['one', 'two']))
  end

  it "should return members of a hash it was called with" do
    result = scope.function_any2array([{ 'key' => 'value' }])
    expect(result).to(eq(['key', 'value']))
  end

  it "should return an empty array if it was called with an empty hash" do
    result = scope.function_any2array([{ }])
    expect(result).to(eq([]))
  end
end
