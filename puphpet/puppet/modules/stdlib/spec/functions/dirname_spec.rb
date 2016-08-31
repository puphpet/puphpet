#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the dirname function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("dirname")).to eq("function_dirname")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_dirname([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if there is more than 1 argument" do
    expect { scope.function_dirname(['a', 'b']) }.to( raise_error(Puppet::ParseError))
  end

  it "should return dirname for an absolute path" do
    result = scope.function_dirname(['/path/to/a/file.ext'])
    expect(result).to(eq('/path/to/a'))
  end

  it "should return dirname for a relative path" do
    result = scope.function_dirname(['path/to/a/file.ext'])
    expect(result).to(eq('path/to/a'))
  end

  it "should complain about hash argument" do
    expect { scope.function_dirname([{}]) }.to( raise_error(Puppet::ParseError))
  end
  it "should complain about list argument" do
    expect { scope.function_dirname([[]]) }.to( raise_error(Puppet::ParseError))
  end
  it "should complain about numeric argument" do
    expect { scope.function_dirname([2112]) }.to( raise_error(Puppet::ParseError))
  end
end
