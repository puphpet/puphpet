#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the strftime function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("strftime")).to eq("function_strftime")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_strftime([]) }.to( raise_error(Puppet::ParseError))
  end

  it "using %s should be higher then when I wrote this test" do
    result = scope.function_strftime(["%s"])
    expect(result.to_i).to(be > 1311953157)
  end

  it "using %s should be lower then 1.5 trillion" do
    result = scope.function_strftime(["%s"])
    expect(result.to_i).to(be < 1500000000)
  end

  it "should return a date when given %Y-%m-%d" do
    result = scope.function_strftime(["%Y-%m-%d"])
    expect(result).to match(/^\d{4}-\d{2}-\d{2}$/)
  end
end
