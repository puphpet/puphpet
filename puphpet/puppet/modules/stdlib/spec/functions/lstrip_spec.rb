#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the lstrip function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("lstrip")).to eq("function_lstrip")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_lstrip([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should lstrip a string" do
    result = scope.function_lstrip(["  asdf"])
    expect(result).to(eq('asdf'))
  end

  it "should accept objects which extend String" do
    class AlsoString < String
    end

    value = AlsoString.new("  asdf")
    result = scope.function_lstrip([value])
    result.should(eq("asdf"))
  end
end
