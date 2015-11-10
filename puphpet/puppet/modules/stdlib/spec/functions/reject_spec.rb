#!/usr/bin/env ruby

require 'spec_helper'

describe "the reject function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("reject")).to eq("function_reject")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_reject([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should reject contents from an array" do
    result = scope.function_reject([["1111", "aaabbb","bbbccc","dddeee"], "bbb"])
    expect(result).to(eq(["1111", "dddeee"]))
  end
end
