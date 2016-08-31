#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the pick function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("pick")).to eq("function_pick")
  end

  it 'should return the correct value' do
    expect(scope.function_pick(['first', 'second'])).to eq('first')
  end

  it 'should return the correct value if the first value is empty' do
    expect(scope.function_pick(['', 'second'])).to eq('second')
  end

  it 'should remove empty string values' do
    expect(scope.function_pick(['', 'first'])).to eq('first')
  end

  it 'should remove :undef values' do
    expect(scope.function_pick([:undef, 'first'])).to eq('first')
  end

  it 'should remove :undefined values' do
    expect(scope.function_pick([:undefined, 'first'])).to eq('first')
  end

  it 'should error if no values are passed' do
    expect { scope.function_pick([]) }.to( raise_error(Puppet::ParseError, "pick(): must receive at least one non empty value"))
  end
end
