#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "the min function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("min")).to eq("function_min")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_min([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should be able to compare strings" do
    expect(scope.function_min(["albatross","dog","horse"])).to(eq("albatross"))
  end

  it "should be able to compare numbers" do
    expect(scope.function_min([6,8,4])).to(eq(4))
  end

  it "should be able to compare a number with a stringified number" do
    expect(scope.function_min([1,"2"])).to(eq(1))
  end
end
