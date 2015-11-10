#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the delete_undef_values function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("delete_undef_values")).to eq("function_delete_undef_values")
  end

  it "should raise a ParseError if there is less than 1 argument" do
    expect { scope.function_delete_undef_values([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if the argument is not Array nor Hash" do
    expect { scope.function_delete_undef_values(['']) }.to( raise_error(Puppet::ParseError))
    expect { scope.function_delete_undef_values([nil]) }.to( raise_error(Puppet::ParseError))
  end

  it "should delete all undef items from Array and only these" do
    result = scope.function_delete_undef_values([['a',:undef,'c','undef']])
    expect(result).to(eq(['a','c','undef']))
  end

  it "should delete all undef items from Hash and only these" do
    result = scope.function_delete_undef_values([{'a'=>'A','b'=>:undef,'c'=>'C','d'=>'undef'}])
    expect(result).to(eq({'a'=>'A','c'=>'C','d'=>'undef'}))
  end

  it "should not change origin array passed as argument" do
    origin_array = ['a',:undef,'c','undef']
    result = scope.function_delete_undef_values([origin_array])
    expect(origin_array).to(eq(['a',:undef,'c','undef']))
  end

  it "should not change origin hash passed as argument" do
    origin_hash = { 'a' => 1, 'b' => :undef, 'c' => 'undef' }
    result = scope.function_delete_undef_values([origin_hash])
    expect(origin_hash).to(eq({ 'a' => 1, 'b' => :undef, 'c' => 'undef' }))
  end
end
