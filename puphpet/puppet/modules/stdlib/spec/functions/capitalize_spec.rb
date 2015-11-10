#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the capitalize function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("capitalize")).to eq("function_capitalize")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_capitalize([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should capitalize the beginning of a string" do
    result = scope.function_capitalize(["abc"])
    expect(result).to(eq("Abc"))
  end

  it "should accept objects which extend String" do
    class AlsoString < String
    end

    value = AlsoString.new('abc')
    result = scope.function_capitalize([value])
    result.should(eq('Abc'))
  end
end
