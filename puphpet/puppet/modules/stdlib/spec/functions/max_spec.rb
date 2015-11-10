#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "the max function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("max")).to eq("function_max")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_max([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should be able to compare strings" do
    expect(scope.function_max(["albatross","dog","horse"])).to(eq("horse"))
  end

  it "should be able to compare numbers" do
    expect(scope.function_max([6,8,4])).to(eq(8))
  end

  it "should be able to compare a number with a stringified number" do
    expect(scope.function_max([1,"2"])).to(eq("2"))
  end
end
