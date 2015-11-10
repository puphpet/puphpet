#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "the ceiling function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("ceiling")).to eq("function_ceiling")
  end

  it "should raise a ParseError if there is less than 1 argument" do
    expect { scope.function_ceiling([]) }.to( raise_error(Puppet::ParseError, /Wrong number of arguments/))
  end

  it "should should raise a ParseError if input isn't numeric (eg. String)" do
    expect { scope.function_ceiling(["foo"]) }.to( raise_error(Puppet::ParseError, /Wrong argument type/))
  end

  it "should should raise a ParseError if input isn't numeric (eg. Boolean)" do
    expect { scope.function_ceiling([true]) }.to( raise_error(Puppet::ParseError, /Wrong argument type/))
  end

  it "should return an integer when a numeric type is passed" do
    result = scope.function_ceiling([12.4])
    expect(result.is_a?(Integer)).to(eq(true))
  end

  it "should return the input when an integer is passed" do
    result = scope.function_ceiling([7])
    expect(result).to(eq(7))
  end

  it "should return the smallest integer greater than or equal to the input" do
    result = scope.function_ceiling([3.8])
    expect(result).to(eq(4))
  end
end

