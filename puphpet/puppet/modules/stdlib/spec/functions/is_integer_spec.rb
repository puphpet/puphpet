#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the is_integer function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("is_integer")).to eq("function_is_integer")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_is_integer([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should return true if an integer" do
    result = scope.function_is_integer(["3"])
    expect(result).to(eq(true))
  end

  it "should return true if a negative integer" do
    result = scope.function_is_integer(["-7"])
    expect(result).to(eq(true))
  end

  it "should return false if a float" do
    result = scope.function_is_integer(["3.2"])
    expect(result).to(eq(false))
  end

  it "should return false if a string" do
    result = scope.function_is_integer(["asdf"])
    expect(result).to(eq(false))
  end

  it "should return true if an integer is created from an arithmetical operation" do
    result = scope.function_is_integer([3*2])
    expect(result).to(eq(true))
  end

  it "should return false if an array" do
    result = scope.function_is_numeric([["asdf"]])
    expect(result).to(eq(false))
  end

  it "should return false if a hash" do
    result = scope.function_is_numeric([{"asdf" => false}])
    expect(result).to(eq(false))
  end

  it "should return false if a boolean" do
    result = scope.function_is_numeric([true])
    expect(result).to(eq(false))
  end

  it "should return false if a whitespace is in the string" do
    result = scope.function_is_numeric([" -1324"])
    expect(result).to(eq(false))
  end

  it "should return false if it is zero prefixed" do
    result = scope.function_is_numeric(["0001234"])
    expect(result).to(eq(false))
  end

  it "should return false if it is wrapped inside an array" do
    result = scope.function_is_numeric([[1234]])
    expect(result).to(eq(false))
  end
end
