#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the intersection function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("intersection")).to eq("function_intersection")
  end

  it "should raise a ParseError if there are fewer than 2 arguments" do
    expect { scope.function_intersection([]) }.to( raise_error(Puppet::ParseError) )
  end

  it "should return the intersection of two arrays" do
    result = scope.function_intersection([["a","b","c"],["b","c","d"]])
    expect(result).to(eq(["b","c"]))
  end
end
