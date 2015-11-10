#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the is_domain_name function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("is_domain_name")).to eq("function_is_domain_name")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_is_domain_name([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should return true if a valid short domain name" do
    result = scope.function_is_domain_name(["x.com"])
    expect(result).to(be_truthy)
  end

  it "should return true if the domain is ." do
    result = scope.function_is_domain_name(["."])
    expect(result).to(be_truthy)
  end

  it "should return true if the domain is x.com." do
    result = scope.function_is_domain_name(["x.com."])
    expect(result).to(be_truthy)
  end

  it "should return true if a valid domain name" do
    result = scope.function_is_domain_name(["foo.bar.com"])
    expect(result).to(be_truthy)
  end

  it "should allow domain parts to start with numbers" do
    result = scope.function_is_domain_name(["3foo.2bar.com"])
    expect(result).to(be_truthy)
  end

  it "should allow domain to end with a dot" do
    result = scope.function_is_domain_name(["3foo.2bar.com."])
    expect(result).to(be_truthy)
  end

  it "should allow a single part domain" do
    result = scope.function_is_domain_name(["orange"])
    expect(result).to(be_truthy)
  end

  it "should return false if domain parts start with hyphens" do
    result = scope.function_is_domain_name(["-3foo.2bar.com"])
    expect(result).to(be_falsey)
  end

  it "should return true if domain contains hyphens" do
    result = scope.function_is_domain_name(["3foo-bar.2bar-fuzz.com"])
    expect(result).to(be_truthy)
  end

  it "should return false if domain name contains spaces" do
    result = scope.function_is_domain_name(["not valid"])
    expect(result).to(be_falsey)
  end

  # Values obtained from Facter values will be frozen strings
  # in newer versions of Facter:
  it "should not throw an exception if passed a frozen string" do
    result = scope.function_is_domain_name(["my.domain.name".freeze])
    expect(result).to(be_truthy)
  end

  it "should return false if top-level domain is not entirely alphabetic" do
    result = scope.function_is_domain_name(["kiwi.2bar"])
    expect(result).to(be_falsey)
  end

  it "should return false if domain name has the dotted-decimal form, e.g. an IPv4 address" do
    result = scope.function_is_domain_name(["192.168.1.1"])
    expect(result).to(be_falsey)
  end
end
