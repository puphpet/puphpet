#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "the to_bytes function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("to_bytes")).to eq("function_to_bytes")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_to_bytes([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should convert kB to B" do
    result = scope.function_to_bytes(["4 kB"])
    expect(result).to(eq(4096))
  end

  it "should convert MB to B" do
    result = scope.function_to_bytes(["4 MB"])
    expect(result).to(eq(4194304))
  end

  it "should convert GB to B" do
    result = scope.function_to_bytes(["4 GB"])
    expect(result).to(eq(4294967296))
  end

  it "should convert TB to B" do
    result = scope.function_to_bytes(["4 TB"])
    expect(result).to(eq(4398046511104))
  end

  it "should convert PB to B" do
    result = scope.function_to_bytes(["4 PB"])
    expect(result).to(eq(4503599627370496))
  end

  it "should convert PB to B" do
    result = scope.function_to_bytes(["4 EB"])
    expect(result).to(eq(4611686018427387904))
  end

  it "should work without B in unit" do
    result = scope.function_to_bytes(["4 k"])
    expect(result).to(eq(4096))
  end

  it "should work without a space before unit" do
    result = scope.function_to_bytes(["4k"])
    expect(result).to(eq(4096))
  end

  it "should work without a unit" do
    result = scope.function_to_bytes(["5678"])
    expect(result).to(eq(5678))
  end

  it "should convert fractions" do
    result = scope.function_to_bytes(["1.5 kB"])
    expect(result).to(eq(1536))
  end

  it "should convert scientific notation" do
    result = scope.function_to_bytes(["1.5e2 B"])
    expect(result).to(eq(150))
  end

  it "should do nothing with a positive number" do
    result = scope.function_to_bytes([5678])
    expect(result).to(eq(5678))
  end

  it "should should raise a ParseError if input isn't a number" do
    expect { scope.function_to_bytes(["foo"]) }.to( raise_error(Puppet::ParseError))
  end

  it "should should raise a ParseError if prefix is unknown" do
    expect { scope.function_to_bytes(["5 uB"]) }.to( raise_error(Puppet::ParseError))
  end
end
