#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the str2bool function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("str2bool")).to eq("function_str2bool")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_str2bool([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should convert string 'true' to true" do
    result = scope.function_str2bool(["true"])
    expect(result).to(eq(true))
  end

  it "should convert string 'undef' to false" do
    result = scope.function_str2bool(["undef"])
    expect(result).to(eq(false))
  end

  it "should return the boolean it was called with" do
    result = scope.function_str2bool([true])
    expect(result).to(eq(true))
    result = scope.function_str2bool([false])
    expect(result).to(eq(false))
  end
end
