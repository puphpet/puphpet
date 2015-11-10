#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the fqdn_rotate function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("fqdn_rotate")).to eq("function_fqdn_rotate")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_fqdn_rotate([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should rotate a string and the result should be the same size" do
    scope.expects(:lookupvar).with("::fqdn").returns("127.0.0.1")
    result = scope.function_fqdn_rotate(["asdf"])
    expect(result.size).to(eq(4))
  end

  it "should rotate a string to give the same results for one host" do
    scope.expects(:lookupvar).with("::fqdn").returns("127.0.0.1").twice
    expect(scope.function_fqdn_rotate(["abcdefg"])).to eql(scope.function_fqdn_rotate(["abcdefg"]))
  end

  it "should rotate a string to give different values on different hosts" do
     scope.expects(:lookupvar).with("::fqdn").returns("127.0.0.1")
     val1 = scope.function_fqdn_rotate(["abcdefghijklmnopqrstuvwxyz01234567890987654321"])
     scope.expects(:lookupvar).with("::fqdn").returns("127.0.0.2")
     val2 = scope.function_fqdn_rotate(["abcdefghijklmnopqrstuvwxyz01234567890987654321"])
     expect(val1).not_to eql(val2)
  end

  it "should accept objects which extend String" do
    class AlsoString < String
    end

    scope.expects(:lookupvar).with("::fqdn").returns("127.0.0.1")
    value = AlsoString.new("asdf")
    result = scope.function_fqdn_rotate([value])
    result.size.should(eq(4))
  end

  it "should use the Puppet::Util.deterministic_rand function if available" do
    scope.expects(:lookupvar).with("::fqdn").returns("127.0.0.1")
    if Puppet::Util.respond_to?(:deterministic_rand)
      Puppet::Util.expects(:deterministic_rand).with(113646079810780526294648115052177588845,4)
    end
    scope.function_fqdn_rotate(["asdf"])
  end

  it "should not leave the global seed in a deterministic state" do
    scope.expects(:lookupvar).with("::fqdn").returns("127.0.0.1").twice
    scope.function_fqdn_rotate(["asdf"])
    rand1 = rand()
    scope.function_fqdn_rotate(["asdf"])
    rand2 = rand()
    expect(rand1).not_to eql(rand2)
  end
end
