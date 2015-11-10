#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe Puppet::Parser::Functions.function(:private) do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  subject do
    function_name = Puppet::Parser::Functions.function(:private)
    scope.method(function_name)
  end

  it 'should issue a warning' do
    scope.expects(:warning).with("private() DEPRECATED: This function will cease to function on Puppet 4; please use assert_private() before upgrading to puppet 4 for backwards-compatibility, or migrate to the new parser's typing system.")
    subject.call []
  end

  context "when called from inside module" do
    it "should not fail" do
      scope.expects(:lookupvar).with('module_name').returns('foo')
      scope.expects(:lookupvar).with('caller_module_name').returns('foo')
      expect {
        subject.call []
      }.not_to raise_error
    end
  end

  context "with an explicit failure message" do
    it "prints the failure message on error" do
      scope.expects(:lookupvar).with('module_name').returns('foo')
      scope.expects(:lookupvar).with('caller_module_name').returns('bar')
      expect {
        subject.call ['failure message!']
      }.to raise_error Puppet::ParseError, /failure message!/
    end
  end

  context "when called from private class" do
    it "should fail with a class error message" do
      scope.expects(:lookupvar).with('module_name').returns('foo')
      scope.expects(:lookupvar).with('caller_module_name').returns('bar')
      scope.source.expects(:name).returns('foo::baz')
      scope.source.expects(:type).returns('hostclass')
      expect {
        subject.call []
      }.to raise_error Puppet::ParseError, /Class foo::baz is private/
    end
  end

  context "when called from private definition" do
    it "should fail with a class error message" do
      scope.expects(:lookupvar).with('module_name').returns('foo')
      scope.expects(:lookupvar).with('caller_module_name').returns('bar')
      scope.source.expects(:name).returns('foo::baz')
      scope.source.expects(:type).returns('definition')
      expect {
        subject.call []
      }.to raise_error Puppet::ParseError, /Definition foo::baz is private/
    end
  end
end
