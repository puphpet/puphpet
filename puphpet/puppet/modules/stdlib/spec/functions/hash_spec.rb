#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the hash function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("hash")).to eq("function_hash")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_hash([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should convert an array to a hash" do
    result = scope.function_hash([['a',1,'b',2,'c',3]])
    expect(result).to(eq({'a'=>1,'b'=>2,'c'=>3}))
  end
end
