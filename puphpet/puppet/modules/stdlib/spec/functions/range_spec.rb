#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the range function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "exists" do
    expect(Puppet::Parser::Functions.function("range")).to eq("function_range")
  end

  it "raises a ParseError if there is less than 1 arguments" do
    expect { scope.function_range([]) }.to raise_error Puppet::ParseError, /Wrong number of arguments.*0 for 1/
  end

  describe 'with a letter range' do
    it "returns a letter range" do
      result = scope.function_range(["a","d"])
      expect(result).to eq ['a','b','c','d']
    end

    it "returns a letter range given a step of 1" do
      result = scope.function_range(["a","d","1"])
      expect(result).to eq ['a','b','c','d']
    end

    it "returns a stepped letter range" do
      result = scope.function_range(["a","d","2"])
      expect(result).to eq ['a','c']
    end

    it "returns a stepped letter range given a negative step" do
      result = scope.function_range(["a","d","-2"])
      expect(result).to eq ['a','c']
    end
  end

  describe 'with a number range' do
    it "returns a number range" do
      result = scope.function_range(["1","4"])
      expect(result).to eq [1,2,3,4]
    end

    it "returns a number range given a step of 1" do
      result = scope.function_range(["1","4","1"])
      expect(result).to eq [1,2,3,4]
    end

    it "returns a stepped number range" do
      result = scope.function_range(["1","4","2"])
      expect(result).to eq [1,3]
    end

    it "returns a stepped number range given a negative step" do
      result = scope.function_range(["1","4","-2"])
      expect(result).to eq [1,3]
    end
  end

  describe 'with a numeric-like string range' do
    it "works with padded hostname like strings" do
      expected = ("host01".."host10").to_a
      expect(scope.function_range(["host01","host10"])).to eq expected
    end

    it "coerces zero padded digits to integers" do
      expected = (0..10).to_a
      expect(scope.function_range(["00", "10"])).to eq expected
    end
  end

  describe 'with a numeric range' do
    it "returns a range of numbers" do
      expected = (1..10).to_a
      expect(scope.function_range([1,10])).to eq expected
    end
    it "returns a range of numbers with step parameter" do
      expected = (1..10).step(2).to_a
      expect(scope.function_range([1,10,2])).to eq expected
    end
    it "works with mixed numeric like strings and numeric arguments" do
      expected = (1..10).to_a
      expect(scope.function_range(['1',10])).to eq expected
      expect(scope.function_range([1,'10'])).to eq expected
    end
  end
end
