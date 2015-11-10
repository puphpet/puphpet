#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the is_array function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("is_array")).to eq("function_is_array")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_is_array([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should return true if passed an array" do
    result = scope.function_is_array([[1,2,3]])
    expect(result).to(eq(true))
  end

  it "should return false if passed a hash" do
    result = scope.function_is_array([{'a'=>1}])
    expect(result).to(eq(false))
  end

  it "should return false if passed a string" do
    result = scope.function_is_array(["asdf"])
    expect(result).to(eq(false))
  end
end
