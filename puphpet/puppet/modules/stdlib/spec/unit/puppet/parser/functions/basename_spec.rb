#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the basename function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    Puppet::Parser::Functions.function("basename").should == "function_basename"
  end

  it "should raise a ParseError if there is less than 1 argument" do
    lambda { scope.function_basename([]) }.should( raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if there are more than 2 arguments" do
    lambda { scope.function_basename(['a', 'b', 'c']) }.should( raise_error(Puppet::ParseError))
  end

  it "should return basename for an absolute path" do
    result = scope.function_basename(['/path/to/a/file.ext'])
    result.should(eq('file.ext'))
  end

  it "should return basename for a relative path" do
    result = scope.function_basename(['path/to/a/file.ext'])
    result.should(eq('file.ext'))
  end

  it "should strip extention when extension specified (absolute path)" do
    result = scope.function_basename(['/path/to/a/file.ext', '.ext'])
    result.should(eq('file'))
  end

  it "should strip extention when extension specified (relative path)" do
    result = scope.function_basename(['path/to/a/file.ext', '.ext'])
    result.should(eq('file'))
  end

  it "should complain about non-string first argument" do
    lambda { scope.function_basename([[]]) }.should( raise_error(Puppet::ParseError))
  end

  it "should complain about non-string second argument" do
    lambda { scope.function_basename(['/path/to/a/file.ext', []]) }.should( raise_error(Puppet::ParseError))
  end
end
