#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the chomp function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("chomp")).to eq("function_chomp")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_chomp([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should chomp the end of a string" do
    result = scope.function_chomp(["abc\n"])
    expect(result).to(eq("abc"))
  end

  it "should accept objects which extend String" do
    class AlsoString < String
    end

    value = AlsoString.new("abc\n")
    result = scope.function_chomp([value])
    result.should(eq("abc"))
  end
end
