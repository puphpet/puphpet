#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the concat function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should raise a ParseError if the client does not provide at least two arguments" do
    expect { scope.function_concat([]) }.to(raise_error(Puppet::ParseError))
    expect { scope.function_concat([[1]]) }.to(raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if the first parameter is not an array" do
    expect { scope.function_concat([1, []])}.to(raise_error(Puppet::ParseError))
  end

  it "should not raise a ParseError if the client provides more than two arguments" do
    expect { scope.function_concat([[1],[2],[3]]) }.not_to raise_error
  end

  it "should be able to concat an array" do
    result = scope.function_concat([['1','2','3'],['4','5','6']])
    expect(result).to(eq(['1','2','3','4','5','6']))
  end

  it "should be able to concat a primitive to an array" do
    result = scope.function_concat([['1','2','3'],'4'])
    expect(result).to(eq(['1','2','3','4']))
  end

  it "should not accidentally flatten nested arrays" do
    result = scope.function_concat([['1','2','3'],[['4','5'],'6']])
    expect(result).to(eq(['1','2','3',['4','5'],'6']))
  end

  it "should leave the original array intact" do
    array_original = ['1','2','3']
    result = scope.function_concat([array_original,['4','5','6']])
    array_original.should(eq(['1','2','3']))
  end

  it "should be able to concat multiple arrays" do
    result = scope.function_concat([['1','2','3'],['4','5','6'],['7','8','9']])
    expect(result).to(eq(['1','2','3','4','5','6','7','8','9']))
  end

  it "should be able to concat mix of primitives and arrays to a final array" do
    result = scope.function_concat([['1','2','3'],'4',['5','6','7']])
    expect(result).to(eq(['1','2','3','4','5','6','7']))
  end
end
