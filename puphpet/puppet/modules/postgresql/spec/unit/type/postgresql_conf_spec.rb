#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:postgresql_conf) do
  before do
    @provider_class = described_class.provide(:simple) { mk_resource_methods }
    @provider_class.stub(:suitable?).and_return true
    described_class.stub(:defaultprovider).and_return @provider_class
  end

  describe "namevar validation" do
    it "should have :name as its namevar" do
      expect(described_class.key_attributes).to eq([:name])
    end
    it "should not invalid names" do
      expect { described_class.new(:name => 'foo bar') }.to raise_error(Puppet::Error, /Invalid value/)
    end
    it "should allow dots in names" do
      expect { described_class.new(:name => 'foo.bar') }.to_not raise_error
    end
  end

  describe "when validating attributes" do
    [:name, :provider].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    [:value, :target].each do |property|
      it "should have a #{property} property" do
        expect(described_class.attrtype(property)).to eq(:property)
      end
    end
  end

  describe "when validating values" do
    describe "ensure" do
      it "should support present as a value for ensure" do
        expect { described_class.new(:name => 'foo', :ensure => :present) }.to_not raise_error
      end
      it "should support absent as a value for ensure" do
        expect { described_class.new(:name => 'foo', :ensure => :absent) }.to_not raise_error
      end
      it "should not support other values" do
        expect { described_class.new(:name => 'foo', :ensure => :foo) }.to raise_error(Puppet::Error, /Invalid value/)
      end
    end
  end
end
