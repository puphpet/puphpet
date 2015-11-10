#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the size function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("size")).to eq("function_size")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_size([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should return the size of a string" do
    result = scope.function_size(["asdf"])
    expect(result).to(eq(4))
  end

  it "should return the size of an array" do
    result = scope.function_size([["a","b","c"]])
    expect(result).to(eq(3))
  end
end
