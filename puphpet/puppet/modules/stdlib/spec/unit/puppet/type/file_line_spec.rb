#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'tempfile'
describe Puppet::Type.type(:file_line) do
  let :file_line do
    Puppet::Type.type(:file_line).new(:name => 'foo', :line => 'line', :path => '/tmp/path')
  end
  it 'should accept a line and path' do
    file_line[:line] = 'my_line'
    expect(file_line[:line]).to eq('my_line')
    file_line[:path] = '/my/path'
    expect(file_line[:path]).to eq('/my/path')
  end
  it 'should accept a match regex' do
    file_line[:match] = '^foo.*$'
    expect(file_line[:match]).to eq('^foo.*$')
  end
  it 'should accept a match regex that does not match the specified line' do
    expect {
      Puppet::Type.type(:file_line).new(
          :name   => 'foo',
          :path   => '/my/path',
          :line   => 'foo=bar',
          :match  => '^bar=blah$'
    )}.not_to raise_error
  end
  it 'should accept a match regex that does match the specified line' do
    expect {
      Puppet::Type.type(:file_line).new(
          :name   => 'foo',
          :path   => '/my/path',
          :line   => 'foo=bar',
          :match  => '^\s*foo=.*$'
      )}.not_to raise_error
  end
  it 'should accept posix filenames' do
    file_line[:path] = '/tmp/path'
    expect(file_line[:path]).to eq('/tmp/path')
  end
  it 'should not accept unqualified path' do
    expect { file_line[:path] = 'file' }.to raise_error(Puppet::Error, /File paths must be fully qualified/)
  end
  it 'should require that a line is specified' do
    expect { Puppet::Type.type(:file_line).new(:name => 'foo', :path => '/tmp/file') }.to raise_error(Puppet::Error, /Both line and path are required attributes/)
  end
  it 'should require that a file is specified' do
    expect { Puppet::Type.type(:file_line).new(:name => 'foo', :line => 'path') }.to raise_error(Puppet::Error, /Both line and path are required attributes/)
  end
  it 'should default to ensure => present' do
    expect(file_line[:ensure]).to eq :present
  end

  it "should autorequire the file it manages" do
    catalog = Puppet::Resource::Catalog.new
    file = Puppet::Type.type(:file).new(:name => "/tmp/path")
    catalog.add_resource file
    catalog.add_resource file_line

    relationship = file_line.autorequire.find do |rel|
      (rel.source.to_s == "File[/tmp/path]") and (rel.target.to_s == file_line.to_s)
    end
    expect(relationship).to be_a Puppet::Relationship
  end

  it "should not autorequire the file it manages if it is not managed" do
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource file_line
    expect(file_line.autorequire).to be_empty
  end
end
