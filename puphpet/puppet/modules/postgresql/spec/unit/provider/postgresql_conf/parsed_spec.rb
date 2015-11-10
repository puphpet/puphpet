require 'spec_helper'
require "tempfile"

provider_class = Puppet::Type.type(:postgresql_conf).provider(:parsed)

describe provider_class do
  let(:title) { 'postgresql_conf' }
  let(:provider) {
    conf_class = Puppet::Type.type(:postgresql_conf)
    provider = conf_class.provider(:parsed)
    conffile = tmpfilename('postgresql.conf')
    provider.any_instance.stub(:target).and_return conffile
    provider
  }

  before do
  end

  after :each do
    provider.initvars
  end

  describe "simple configuration that should be allowed" do
    it "should parse a simple ini line" do
      expect(provider.parse_line("listen_addreses = '*'")).to eq(
        { :name=>"listen_addreses", :value=>"*", :comment=>nil, :record_type=>:parsed }
      )
    end

    it "should parse a simple ini line (2)" do
      expect(provider.parse_line("   listen_addreses = '*'")).to eq(
        { :name=>"listen_addreses", :value=>"*", :comment=>nil, :record_type=>:parsed }
      )
    end

    it "should parse a simple ini line (3)" do
      expect(provider.parse_line("listen_addreses = '*' # dont mind me")).to eq(
        { :name=>"listen_addreses", :value=>"*", :comment=>"dont mind me", :record_type=>:parsed }
      )
    end

    it "should parse a comment" do
      expect(provider.parse_line("# dont mind me")).to eq(
        { :line=>"# dont mind me", :record_type=>:comment }
      )
    end

    it "should parse a comment (2)" do
      expect(provider.parse_line(" \t# dont mind me")).to eq(
        { :line=>" \t# dont mind me", :record_type=>:comment }
      )
    end

    it "should allow includes" do
      expect(provider.parse_line("include puppetextra")).to eq(
        { :name=>"include", :value=>"puppetextra", :comment=>nil, :record_type=>:parsed }
      )
    end

    it "should allow numbers through without quotes" do
      expect(provider.parse_line("wal_keep_segments = 32")).to eq(
        { :name=>"wal_keep_segments", :value=>"32", :comment=>nil, :record_type=>:parsed }
      )
    end

    it "should allow blanks through " do
      expect(provider.parse_line("")).to eq(
        { :line=>"", :record_type=>:blank }
      )
    end

    it "should parse keys with dots " do
      expect(provider.parse_line("auto_explain.log_min_duration = 1ms")).to eq(
        { :name => "auto_explain.log_min_duration", :value => "1ms", :comment => nil, :record_type => :parsed }
      )
    end
  end

  describe "configuration that should be set" do
    it "should set comment lines" do
      expect(provider.to_line({ :line=>"# dont mind me", :record_type=>:comment })).to eq(
        '# dont mind me'
      )
    end

    it "should set blank lines" do
      expect(provider.to_line({ :line=>"", :record_type=>:blank })).to eq(
        ''
      )
    end

    it "should set simple configuration" do
      expect(provider.to_line({:name=>"listen_addresses", :value=>"*", :comment=>nil, :record_type=>:parsed })).to eq(
        "listen_addresses = '*'"
      )
    end

    it "should set simple configuration with period in name" do
      expect(provider.to_line({:name => "auto_explain.log_min_duration", :value => '100ms', :comment => nil, :record_type => :parsed })).to eq(
        "auto_explain.log_min_duration = 100ms"
      )
    end

    it "should set simple configuration even with comments" do
      expect(provider.to_line({:name=>"listen_addresses", :value=>"*", :comment=>'dont mind me', :record_type=>:parsed })).to eq(
        "listen_addresses = '*' # dont mind me"
      )
    end

    it 'should quote includes' do
      expect(provider.to_line( {:name=>"include", :value=>"puppetextra", :comment=>nil, :record_type=>:parsed })).to eq(
        "include 'puppetextra'"
      )
    end

    it 'should quote multiple words' do
      expect(provider.to_line( {:name=>"archive_command", :value=>"rsync up", :comment=>nil, :record_type=>:parsed })).to eq(
        "archive_command = 'rsync up'"
      )
    end

    it 'shouldn\'t quote numbers' do
      expect(provider.to_line( {:name=>"wal_segments", :value=>"32", :comment=>nil, :record_type=>:parsed })).to eq(
        "wal_segments = 32"
      )
    end
  end
end

