#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the pick_default function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("pick_default")).to eq("function_pick_default")
  end

  it 'should return the correct value' do
    expect(scope.function_pick_default(['first', 'second'])).to eq('first')
  end

  it 'should return the correct value if the first value is empty' do
    expect(scope.function_pick_default(['', 'second'])).to eq('second')
  end

  it 'should skip empty string values' do
    expect(scope.function_pick_default(['', 'first'])).to eq('first')
  end

  it 'should skip :undef values' do
    expect(scope.function_pick_default([:undef, 'first'])).to eq('first')
  end

  it 'should skip :undefined values' do
    expect(scope.function_pick_default([:undefined, 'first'])).to eq('first')
  end

  it 'should return the empty string if it is the last possibility' do
    expect(scope.function_pick_default([:undef, :undefined, ''])).to eq('')
  end

  it 'should return :undef if it is the last possibility' do
    expect(scope.function_pick_default(['', :undefined, :undef])).to eq(:undef)
  end

  it 'should return :undefined if it is the last possibility' do
    expect(scope.function_pick_default([:undef, '', :undefined])).to eq(:undefined)
  end

  it 'should return the empty string if it is the only possibility' do
    expect(scope.function_pick_default([''])).to eq('')
  end

  it 'should return :undef if it is the only possibility' do
    expect(scope.function_pick_default([:undef])).to eq(:undef)
  end

  it 'should return :undefined if it is the only possibility' do
    expect(scope.function_pick_default([:undefined])).to eq(:undefined)
  end

  it 'should error if no values are passed' do
    expect { scope.function_pick_default([]) }.to raise_error(Puppet::Error, /Must receive at least one argument./)
  end
end
