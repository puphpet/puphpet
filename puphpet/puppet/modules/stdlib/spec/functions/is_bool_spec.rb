#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the is_bool function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("is_bool")).to eq("function_is_bool")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_is_bool([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should return true if passed a TrueClass" do
    result = scope.function_is_bool([true])
    expect(result).to(eq(true))
  end

  it "should return true if passed a FalseClass" do
    result = scope.function_is_bool([false])
    expect(result).to(eq(true))
  end

  it "should return false if passed the string 'true'" do
    result = scope.function_is_bool(['true'])
    expect(result).to(eq(false))
  end

  it "should return false if passed the string 'false'" do
    result = scope.function_is_bool(['false'])
    expect(result).to(eq(false))
  end

  it "should return false if passed an array" do
    result = scope.function_is_bool([["a","b"]])
    expect(result).to(eq(false))
  end

  it "should return false if passed a hash" do
    result = scope.function_is_bool([{"a" => "b"}])
    expect(result).to(eq(false))
  end
end
