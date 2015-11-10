#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the time function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("time")).to eq("function_time")
  end

  it "should raise a ParseError if there is more than 2 arguments" do
    expect { scope.function_time(['','']) }.to( raise_error(Puppet::ParseError))
  end

  it "should return a number" do
    result = scope.function_time([])
    expect(result).to be_an(Integer)
  end

  it "should be higher then when I wrote this test" do
    result = scope.function_time([])
    expect(result).to(be > 1311953157)
  end

  it "should be lower then 1.5 trillion" do
    result = scope.function_time([])
    expect(result).to(be < 1500000000)
  end
end
