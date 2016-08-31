#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the flatten function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }
  it "should exist" do
    expect(Puppet::Parser::Functions.function("flatten")).to eq("function_flatten")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_flatten([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if there is more than 1 argument" do
    expect { scope.function_flatten([[], []]) }.to( raise_error(Puppet::ParseError))
  end

  it "should flatten a complex data structure" do
    result = scope.function_flatten([["a","b",["c",["d","e"],"f","g"]]])
    expect(result).to(eq(["a","b","c","d","e","f","g"]))
  end

  it "should do nothing to a structure that is already flat" do
    result = scope.function_flatten([["a","b","c","d"]])
    expect(result).to(eq(["a","b","c","d"]))
  end
end
