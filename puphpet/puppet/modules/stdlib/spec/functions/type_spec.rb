#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the type function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }
  it "should exist" do
    expect(Puppet::Parser::Functions.function("type")).to eq("function_type")
  end

  it "should give a deprecation warning when called" do
    scope.expects(:warning).with("type() DEPRECATED: This function will cease to function on Puppet 4; please use type3x() before upgrading to puppet 4 for backwards-compatibility, or migrate to the new parser's typing system.")
    scope.function_type(["aoeu"])
  end

  it "should return string when given a string" do
    result = scope.function_type(["aaabbbbcccc"])
    expect(result).to(eq('string'))
  end

  it "should return array when given an array" do
    result = scope.function_type([["aaabbbbcccc","asdf"]])
    expect(result).to(eq('array'))
  end

  it "should return hash when given a hash" do
    result = scope.function_type([{"a"=>1,"b"=>2}])
    expect(result).to(eq('hash'))
  end

  it "should return integer when given an integer" do
    result = scope.function_type(["1"])
    expect(result).to(eq('integer'))
  end

  it "should return float when given a float" do
    result = scope.function_type(["1.34"])
    expect(result).to(eq('float'))
  end

  it "should return boolean when given a boolean" do
    result = scope.function_type([true])
    expect(result).to(eq('boolean'))
  end
end
