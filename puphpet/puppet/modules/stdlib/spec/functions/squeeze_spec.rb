#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the squeeze function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("squeeze")).to eq("function_squeeze")
  end

  it "should raise a ParseError if there is less than 2 arguments" do
    expect { scope.function_squeeze([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should squeeze a string" do
    result = scope.function_squeeze(["aaabbbbcccc"])
    expect(result).to(eq('abc'))
  end

  it "should squeeze all elements in an array" do
    result = scope.function_squeeze([["aaabbbbcccc","dddfff"]])
    expect(result).to(eq(['abc','df']))
  end
end
