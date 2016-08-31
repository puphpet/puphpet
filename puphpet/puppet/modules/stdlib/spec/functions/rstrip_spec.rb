#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the rstrip function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("rstrip")).to eq("function_rstrip")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_rstrip([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should rstrip a string" do
    result = scope.function_rstrip(["asdf  "])
    expect(result).to(eq('asdf'))
  end

  it "should rstrip each element in an array" do
    result = scope.function_rstrip([["a ","b ", "c "]])
    expect(result).to(eq(['a','b','c']))
  end

  it "should accept objects which extend String" do
    class AlsoString < String
    end

    value = AlsoString.new('asdf ')
    result = scope.function_rstrip([value])
    result.should(eq('asdf'))
  end
end
