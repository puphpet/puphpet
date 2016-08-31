#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the delete_at function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("delete_at")).to eq("function_delete_at")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_delete_at([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should delete an item at specified location from an array" do
    result = scope.function_delete_at([['a','b','c'],1])
    expect(result).to(eq(['a','c']))
  end

  it "should not change origin array passed as argument" do
    origin_array = ['a','b','c','d']
    result = scope.function_delete_at([origin_array, 1])
    expect(origin_array).to(eq(['a','b','c','d']))
  end
end
