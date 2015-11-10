#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the bool2str function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("bool2str")).to eq("function_bool2str")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_bool2str([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should convert true to 'true'" do
    result = scope.function_bool2str([true])
    expect(result).to(eq('true'))
  end

  it "should convert true to a string" do
    result = scope.function_bool2str([true])
    expect(result.class).to(eq(String))
  end

  it "should convert false to 'false'" do
    result = scope.function_bool2str([false])
    expect(result).to(eq('false'))
  end

  it "should convert false to a string" do
    result = scope.function_bool2str([false])
    expect(result.class).to(eq(String))
  end

  it "should not accept a string" do
    expect { scope.function_bool2str(["false"]) }.to( raise_error(Puppet::ParseError))
  end

  it "should not accept a nil value" do
    expect { scope.function_bool2str([nil]) }.to( raise_error(Puppet::ParseError))
  end

  it "should not accept an undef" do
    expect { scope.function_bool2str([:undef]) }.to( raise_error(Puppet::ParseError))
  end
end
