#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the difference function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("difference")).to eq("function_difference")
  end

  it "should raise a ParseError if there are fewer than 2 arguments" do
    expect { scope.function_difference([]) }.to( raise_error(Puppet::ParseError) )
  end

  it "should return the difference between two arrays" do
    result = scope.function_difference([["a","b","c"],["b","c","d"]])
    expect(result).to(eq(["a"]))
  end
end
