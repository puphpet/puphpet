#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "the count function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("count")).to eq("function_count")
  end

  it "should raise a ArgumentError if there is more than 2 arguments" do
    expect { scope.function_count(['foo', 'bar', 'baz']) }.to( raise_error(ArgumentError))
  end

  it "should be able to count arrays" do
    expect(scope.function_count([["1","2","3"]])).to(eq(3))
  end

  it "should be able to count matching elements in arrays" do
    expect(scope.function_count([["1", "2", "2"], "2"])).to(eq(2))
  end

  it "should not count nil or empty strings" do
    expect(scope.function_count([["foo","bar",nil,""]])).to(eq(2))
  end

  it 'does not count an undefined hash key or an out of bound array index (which are both :undef)' do
    expect(scope.function_count([["foo",:undef,:undef]])).to eq(1)
  end
end
