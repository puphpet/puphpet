#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the uriescape function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("uriescape")).to eq("function_uriescape")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_uriescape([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should uriescape a string" do
    result = scope.function_uriescape([":/?#[]@!$&'()*+,;= \"{}"])
    expect(result).to(eq(':/?%23[]@!$&\'()*+,;=%20%22%7B%7D'))
  end

  it "should uriescape an array of strings, while not touching up nonstrings" do
    teststring = ":/?#[]@!$&'()*+,;= \"{}"
    expectstring = ':/?%23[]@!$&\'()*+,;=%20%22%7B%7D'
    result = scope.function_uriescape([[teststring, teststring, 1]])
    expect(result).to(eq([expectstring, expectstring, 1]))
  end

  it "should do nothing if a string is already safe" do
    result = scope.function_uriescape(["ABCdef"])
    expect(result).to(eq('ABCdef'))
  end

  it "should accept objects which extend String" do
    class AlsoString < String
    end

    value = AlsoString.new('abc')
    result = scope.function_uriescape([value])
    result.should(eq('abc'))
  end
end
