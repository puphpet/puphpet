#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the is_hash function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("is_hash")).to eq("function_is_hash")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_is_hash([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should return true if passed a hash" do
    result = scope.function_is_hash([{"a"=>1,"b"=>2}])
    expect(result).to(eq(true))
  end

  it "should return false if passed an array" do
    result = scope.function_is_hash([["a","b"]])
    expect(result).to(eq(false))
  end

  it "should return false if passed a string" do
    result = scope.function_is_hash(["asdf"])
    expect(result).to(eq(false))
  end
end
