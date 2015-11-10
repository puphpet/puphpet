#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the shuffle function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("shuffle")).to eq("function_shuffle")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_shuffle([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should shuffle a string and the result should be the same size" do
    result = scope.function_shuffle(["asdf"])
    expect(result.size).to(eq(4))
  end

  it "should shuffle a string but the sorted contents should still be the same" do
    result = scope.function_shuffle(["adfs"])
    expect(result.split("").sort.join("")).to(eq("adfs"))
  end

  it "should accept objects which extend String" do
    class AlsoString < String
    end

    value = AlsoString.new('asdf')
    result = scope.function_shuffle([value])
    result.size.should(eq(4))
  end
end
