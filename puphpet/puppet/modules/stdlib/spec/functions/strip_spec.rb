#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the strip function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }
  it "should exist" do
    expect(Puppet::Parser::Functions.function("strip")).to eq("function_strip")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_strip([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should strip a string" do
    result = scope.function_strip([" ab cd "])
    expect(result).to(eq('ab cd'))
  end

  it "should accept objects which extend String" do
    class AlsoString < String
    end

    value = AlsoString.new(' as df ')
    result = scope.function_strip([value])
    result.should(eq('as df'))
  end
end
