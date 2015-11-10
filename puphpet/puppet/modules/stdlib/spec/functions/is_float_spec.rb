#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the is_float function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("is_float")).to eq("function_is_float")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_is_float([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should return true if a float" do
    result = scope.function_is_float(["0.12"])
    expect(result).to(eq(true))
  end

  it "should return false if a string" do
    result = scope.function_is_float(["asdf"])
    expect(result).to(eq(false))
  end

  it "should return false if an integer" do
    result = scope.function_is_float(["3"])
    expect(result).to(eq(false))
  end
  it "should return true if a float is created from an arithmetical operation" do
    result = scope.function_is_float([3.2*2])
    expect(result).to(eq(true))
  end
end
