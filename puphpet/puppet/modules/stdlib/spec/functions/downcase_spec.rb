#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the downcase function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("downcase")).to eq("function_downcase")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_downcase([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should downcase a string" do
    result = scope.function_downcase(["ASFD"])
    expect(result).to(eq("asfd"))
  end

  it "should do nothing to a string that is already downcase" do
    result = scope.function_downcase(["asdf asdf"])
    expect(result).to(eq("asdf asdf"))
  end

  it "should accept objects which extend String" do
    class AlsoString < String
    end

    value = AlsoString.new("ASFD")
    result = scope.function_downcase([value])
    result.should(eq('asfd'))
  end
end
