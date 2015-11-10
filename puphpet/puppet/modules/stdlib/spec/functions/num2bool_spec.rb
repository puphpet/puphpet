#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the num2bool function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("num2bool")).to eq("function_num2bool")
  end

  it "should raise a ParseError if there are no arguments" do
    expect { scope.function_num2bool([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if there are more than 1 arguments" do
    expect { scope.function_num2bool(["foo","bar"]) }.to( raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if passed something non-numeric" do
    expect { scope.function_num2bool(["xyzzy"]) }.to( raise_error(Puppet::ParseError))
  end

  it "should return true if passed string 1" do
    result = scope.function_num2bool(["1"])
    expect(result).to(be_truthy)
  end

  it "should return true if passed string 1.5" do
    result = scope.function_num2bool(["1.5"])
    expect(result).to(be_truthy)
  end

  it "should return true if passed number 1" do
    result = scope.function_num2bool([1])
    expect(result).to(be_truthy)
  end

  it "should return false if passed string 0" do
    result = scope.function_num2bool(["0"])
    expect(result).to(be_falsey)
  end

  it "should return false if passed number 0" do
    result = scope.function_num2bool([0])
    expect(result).to(be_falsey)
  end

  it "should return false if passed string -1" do
    result = scope.function_num2bool(["-1"])
    expect(result).to(be_falsey)
  end

  it "should return false if passed string -1.5" do
    result = scope.function_num2bool(["-1.5"])
    expect(result).to(be_falsey)
  end

  it "should return false if passed number -1" do
    result = scope.function_num2bool([-1])
    expect(result).to(be_falsey)
  end

  it "should return false if passed float -1.5" do
    result = scope.function_num2bool([-1.5])
    expect(result).to(be_falsey)
  end
end
