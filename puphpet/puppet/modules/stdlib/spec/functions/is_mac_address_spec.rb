#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the is_mac_address function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("is_mac_address")).to eq("function_is_mac_address")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_is_mac_address([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should return true if a valid mac address" do
    result = scope.function_is_mac_address(["00:a0:1f:12:7f:a0"])
    expect(result).to(eq(true))
  end

  it "should return false if octets are out of range" do
    result = scope.function_is_mac_address(["00:a0:1f:12:7f:g0"])
    expect(result).to(eq(false))
  end

  it "should return false if not valid" do
    result = scope.function_is_mac_address(["not valid"])
    expect(result).to(eq(false))
  end
end
