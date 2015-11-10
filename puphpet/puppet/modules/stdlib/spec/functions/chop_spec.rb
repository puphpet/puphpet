#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the chop function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("chop")).to eq("function_chop")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_chop([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should chop the end of a string" do
    result = scope.function_chop(["asdf\n"])
    expect(result).to(eq("asdf"))
  end

  it "should accept objects which extend String" do
    class AlsoString < String
    end

    value = AlsoString.new("abc\n")
    result = scope.function_chop([value])
    result.should(eq('abc'))
  end
end
