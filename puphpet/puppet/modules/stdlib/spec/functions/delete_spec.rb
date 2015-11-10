#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the delete function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("delete")).to eq("function_delete")
  end

  it "should raise a ParseError if there are fewer than 2 arguments" do
    expect { scope.function_delete([]) }.to(raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if there are greater than 2 arguments" do
    expect { scope.function_delete([[], 'foo', 'bar']) }.to(raise_error(Puppet::ParseError))
  end

  it "should raise a TypeError if a number is passed as the first argument" do
    expect { scope.function_delete([1, 'bar']) }.to(raise_error(TypeError))
  end

  it "should delete all instances of an element from an array" do
    result = scope.function_delete([['a', 'b', 'c', 'b'], 'b'])
    expect(result).to(eq(['a', 'c']))
  end

  it "should delete all instances of a substring from a string" do
    result = scope.function_delete(['foobarbabarz', 'bar'])
    expect(result).to(eq('foobaz'))
  end

  it "should delete a key from a hash" do
    result = scope.function_delete([{'a' => 1, 'b' => 2, 'c' => 3}, 'b'])
    expect(result).to(eq({'a' => 1, 'c' => 3}))
  end

  it 'should accept an array of items to delete' do
    result = scope.function_delete([{'a' => 1, 'b' => 2, 'c' => 3}, ['b', 'c']])
    expect(result).to(eq({'a' => 1}))
  end

  it "should not change origin array passed as argument" do
    origin_array = ['a', 'b', 'c', 'd']
    result = scope.function_delete([origin_array, 'b'])
    expect(origin_array).to(eq(['a', 'b', 'c', 'd']))
  end

  it "should not change the origin string passed as argument" do
    origin_string = 'foobarbabarz'
    result = scope.function_delete([origin_string, 'bar'])
    expect(origin_string).to(eq('foobarbabarz'))
  end

  it "should not change origin hash passed as argument" do
    origin_hash = {'a' => 1, 'b' => 2, 'c' => 3}
    result = scope.function_delete([origin_hash, 'b'])
    expect(origin_hash).to(eq({'a' => 1, 'b' => 2, 'c' => 3}))
  end

end
