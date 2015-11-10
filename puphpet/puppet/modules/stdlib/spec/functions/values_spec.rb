#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the values function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("values")).to eq("function_values")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_values([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should return values from a hash" do
    result = scope.function_values([{'a'=>'1','b'=>'2','c'=>'3'}])
    # =~ is the RSpec::Matchers::MatchArray matcher.
    # A.K.A. "array with same elements" (multiset) matching
    expect(result).to match_array(%w{ 1 2 3 })
  end

  it "should return a multiset" do
    result = scope.function_values([{'a'=>'1','b'=>'3','c'=>'3'}])
    expect(result).to     match_array(%w{ 1 3 3 })
    expect(result).not_to match_array(%w{ 1 3 })
  end

  it "should raise a ParseError unless a Hash is provided" do
    expect { scope.function_values([['a','b','c']]) }.to( raise_error(Puppet::ParseError))
  end
end
