#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the sort function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("sort")).to eq("function_sort")
  end

  it "should raise a ParseError if there is not 1 arguments" do
    expect { scope.function_sort(['','']) }.to( raise_error(Puppet::ParseError))
  end

  it "should sort an array" do
    result = scope.function_sort([["a","c","b"]])
    expect(result).to(eq(['a','b','c']))
  end

  it "should sort a string" do
    result = scope.function_sort(["acb"])
    expect(result).to(eq('abc'))
  end
end
