#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the parsejson function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("parsejson")).to eq("function_parsejson")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_parsejson([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should convert JSON to a data structure" do
    json = <<-EOS
["aaa","bbb","ccc"]
EOS
    result = scope.function_parsejson([json])
    expect(result).to(eq(['aaa','bbb','ccc']))
  end
end
