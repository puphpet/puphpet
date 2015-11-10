#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the grep function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("grep")).to eq("function_grep")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_grep([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should grep contents from an array" do
    result = scope.function_grep([["aaabbb","bbbccc","dddeee"], "bbb"])
    expect(result).to(eq(["aaabbb","bbbccc"]))
  end
end
