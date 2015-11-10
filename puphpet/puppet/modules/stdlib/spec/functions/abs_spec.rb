#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "the abs function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("abs")).to eq("function_abs")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_abs([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should convert a negative number into a positive" do
    result = scope.function_abs(["-34"])
    expect(result).to(eq(34))
  end

  it "should do nothing with a positive number" do
    result = scope.function_abs(["5678"])
    expect(result).to(eq(5678))
  end
end
