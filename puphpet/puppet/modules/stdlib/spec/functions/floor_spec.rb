#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "the floor function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("floor")).to eq("function_floor")
  end

  it "should raise a ParseError if there is less than 1 argument" do
    expect { scope.function_floor([]) }.to( raise_error(Puppet::ParseError, /Wrong number of arguments/))
  end

  it "should should raise a ParseError if input isn't numeric (eg. String)" do
    expect { scope.function_floor(["foo"]) }.to( raise_error(Puppet::ParseError, /Wrong argument type/))
  end

  it "should should raise a ParseError if input isn't numeric (eg. Boolean)" do
    expect { scope.function_floor([true]) }.to( raise_error(Puppet::ParseError, /Wrong argument type/))
  end

  it "should return an integer when a numeric type is passed" do
    result = scope.function_floor([12.4])
    expect(result.is_a?(Integer)).to(eq(true))
  end

  it "should return the input when an integer is passed" do
    result = scope.function_floor([7])
    expect(result).to(eq(7))
  end

  it "should return the largest integer less than or equal to the input" do
    result = scope.function_floor([3.8])
    expect(result).to(eq(3))
  end
end

