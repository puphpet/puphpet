#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the member function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("member")).to eq("function_member")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_member([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should return true if a member is in an array" do
    result = scope.function_member([["a","b","c"], "a"])
    expect(result).to(eq(true))
  end

  it "should return false if a member is not in an array" do
    result = scope.function_member([["a","b","c"], "d"])
    expect(result).to(eq(false))
  end

  it "should return true if a member array is in an array" do
    result = scope.function_member([["a","b","c"], ["a", "b"]])
    expect(result).to(eq(true))
  end

  it "should return false if a member array is not in an array" do
    result = scope.function_member([["a","b","c"], ["d", "e"]])
    expect(result).to(eq(false))
  end
end
