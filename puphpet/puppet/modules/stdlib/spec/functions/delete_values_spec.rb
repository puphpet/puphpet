#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the delete_values function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("delete_values")).to eq("function_delete_values")
  end

  it "should raise a ParseError if there are fewer than 2 arguments" do
    expect { scope.function_delete_values([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if there are greater than 2 arguments" do
    expect { scope.function_delete_values([[], 'foo', 'bar']) }.to( raise_error(Puppet::ParseError))
  end

  it "should raise a TypeError if the argument is not a hash" do
    expect { scope.function_delete_values([1,'bar']) }.to( raise_error(TypeError))
    expect { scope.function_delete_values(['foo','bar']) }.to( raise_error(TypeError))
    expect { scope.function_delete_values([[],'bar']) }.to( raise_error(TypeError))
  end

  it "should delete all instances of a value from a hash" do
    result = scope.function_delete_values([{ 'a'=>'A', 'b'=>'B', 'B'=>'C', 'd'=>'B' },'B'])
    expect(result).to(eq({ 'a'=>'A', 'B'=>'C' }))
  end

  it "should not change origin hash passed as argument" do
    origin_hash = { 'a' => 1, 'b' => 2, 'c' => 3 }
    result = scope.function_delete_values([origin_hash, 2])
    expect(origin_hash).to(eq({ 'a' => 1, 'b' => 2, 'c' => 3 }))
  end

end
