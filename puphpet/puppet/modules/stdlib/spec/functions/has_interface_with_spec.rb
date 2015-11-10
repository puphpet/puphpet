#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe Puppet::Parser::Functions.function(:has_interface_with) do

  let(:scope) do
    PuppetlabsSpec::PuppetInternals.scope
  end

  # The subject of these examples is the method itself.
  subject do
    function_name = Puppet::Parser::Functions.function(:has_interface_with)
    scope.method(function_name)
  end

  # We need to mock out the Facts so we can specify how we expect this function
  # to behave on different platforms.
  context "On Mac OS X Systems" do
    before :each do
      scope.stubs(:lookupvar).with("interfaces").returns('lo0,gif0,stf0,en1,p2p0,fw0,en0,vmnet1,vmnet8,utun0')
    end
    it 'should have loopback (lo0)' do
      expect(subject.call(['lo0'])).to be_truthy
    end
    it 'should not have loopback (lo)' do
      expect(subject.call(['lo'])).to be_falsey
    end
  end
  context "On Linux Systems" do
    before :each do
      scope.stubs(:lookupvar).with("interfaces").returns('eth0,lo')
      scope.stubs(:lookupvar).with("ipaddress").returns('10.0.0.1')
      scope.stubs(:lookupvar).with("ipaddress_lo").returns('127.0.0.1')
      scope.stubs(:lookupvar).with("ipaddress_eth0").returns('10.0.0.1')
      scope.stubs(:lookupvar).with('muppet').returns('kermit')
      scope.stubs(:lookupvar).with('muppet_lo').returns('mspiggy')
      scope.stubs(:lookupvar).with('muppet_eth0').returns('kermit')
    end
    it 'should have loopback (lo)' do
      expect(subject.call(['lo'])).to be_truthy
    end
    it 'should not have loopback (lo0)' do
      expect(subject.call(['lo0'])).to be_falsey
    end
    it 'should have ipaddress with 127.0.0.1' do
      expect(subject.call(['ipaddress', '127.0.0.1'])).to be_truthy
    end
    it 'should have ipaddress with 10.0.0.1' do
      expect(subject.call(['ipaddress', '10.0.0.1'])).to be_truthy
    end
    it 'should not have ipaddress with 10.0.0.2' do
      expect(subject.call(['ipaddress', '10.0.0.2'])).to be_falsey
    end
    it 'should have muppet named kermit' do
      expect(subject.call(['muppet', 'kermit'])).to be_truthy
    end
    it 'should have muppet named mspiggy' do
      expect(subject.call(['muppet', 'mspiggy'])).to be_truthy
    end
    it 'should not have muppet named bigbird' do
      expect(subject.call(['muppet', 'bigbird'])).to be_falsey
    end
  end
end
