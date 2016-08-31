#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the join function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("join")).to eq("function_join")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_join([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should join an array into a string" do
    result = scope.function_join([["a","b","c"], ":"])
    expect(result).to(eq("a:b:c"))
  end
end
