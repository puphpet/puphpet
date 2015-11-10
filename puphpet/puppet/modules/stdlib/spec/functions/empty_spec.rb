#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the empty function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }
  it "should exist" do
    expect(Puppet::Parser::Functions.function("empty")).to eq("function_empty")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_empty([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should return a true for an empty string" do
    result = scope.function_empty([''])
    expect(result).to(eq(true))
  end

  it "should return a false for a non-empty string" do
    result = scope.function_empty(['asdf'])
    expect(result).to(eq(false))
  end

  it "should accept objects which extend String" do
    class AlsoString < String
    end

    value = AlsoString.new()
    result = scope.function_empty([value])
    result.should(eq(true))
  end
end
