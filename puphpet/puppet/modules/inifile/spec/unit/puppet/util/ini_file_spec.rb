require 'spec_helper'
require 'stringio'
require 'puppet/util/ini_file'

describe Puppet::Util::IniFile do
  let(:subject) { Puppet::Util::IniFile.new("/my/ini/file/path") }

  before :each do
    File.should_receive(:file?).with("/my/ini/file/path") { true }
    described_class.should_receive(:readlines).once.with("/my/ini/file/path") do
      sample_content
    end
  end

  context "when parsing a file" do
    let(:sample_content) {
      template = <<-EOS
# This is a comment
[section1]
; This is also a comment
foo=foovalue

bar = barvalue
baz =
[section2]

foo= foovalue2
baz=bazvalue
 ; commented = out setting
    #another comment
 ; yet another comment
 zot = multi word value
 xyzzy['thing1']['thing2']=xyzzyvalue
 l=git log
      EOS
      template.split("\n")
    }

    it "should parse the correct number of sections" do
      # there is always a "global" section, so our count should be 3.
      subject.section_names.length.should == 3
    end

    it "should parse the correct section_names" do
      # there should always be a "global" section named "" at the beginning of the list
      subject.section_names.should == ["", "section1", "section2"]
    end

    it "should expose settings for sections" do
      subject.get_settings("section1").should == {
        "bar" => "barvalue",
        "baz" => "",
        "foo" => "foovalue"
      }

      subject.get_settings("section2").should == {
        "baz" => "bazvalue",
        "foo" => "foovalue2",
        "l" => "git log",
        "xyzzy['thing1']['thing2']" => "xyzzyvalue",
        "zot" => "multi word value"
      }
    end

  end

  context "when parsing a file whose first line is a section" do
    let(:sample_content) {
      template = <<-EOS
[section1]
; This is a comment
foo=foovalue
      EOS
      template.split("\n")
    }

    it "should parse the correct number of sections" do
      # there is always a "global" section, so our count should be 2.
      subject.section_names.length.should == 2
    end

    it "should parse the correct section_names" do
      # there should always be a "global" section named "" at the beginning of the list
      subject.section_names.should == ["", "section1"]
    end

    it "should expose settings for sections" do
      subject.get_value("section1", "foo").should == "foovalue"
    end

  end

  context "when parsing a file with a 'global' section" do
    let(:sample_content) {
      template = <<-EOS
foo = bar
[section1]
; This is a comment
foo=foovalue
      EOS
      template.split("\n")
    }

    it "should parse the correct number of sections" do
      # there is always a "global" section, so our count should be 2.
      subject.section_names.length.should == 2
    end

    it "should parse the correct section_names" do
      # there should always be a "global" section named "" at the beginning of the list
      subject.section_names.should == ["", "section1"]
    end

    it "should expose settings for sections" do
      subject.get_value("", "foo").should == "bar"
      subject.get_value("section1", "foo").should == "foovalue"
    end
  end

  context "when updating a file with existing empty values" do
    let(:sample_content) {
      template = <<-EOS
[section1]
foo=
#bar=
#xyzzy['thing1']['thing2']='xyzzyvalue'
      EOS
      template.split("\n")
    }

    it "should properly update uncommented values" do
      subject.get_value("section1", "far").should == nil
      subject.set_value("section1", "foo", "foovalue")
      subject.get_value("section1", "foo").should == "foovalue"
    end

    it "should properly update commented values" do
      subject.get_value("section1", "bar").should == nil
      subject.set_value("section1", "bar", "barvalue")
      subject.get_value("section1", "bar").should == "barvalue"
      subject.get_value("section1", "xyzzy['thing1']['thing2']").should == nil
      subject.set_value("section1", "xyzzy['thing1']['thing2']", "xyzzyvalue")
      subject.get_value("section1", "xyzzy['thing1']['thing2']").should == "xyzzyvalue"
    end

    it "should properly add new empty values" do
      subject.get_value("section1", "baz").should == nil
      subject.set_value("section1", "baz", "bazvalue")
      subject.get_value("section1", "baz").should == "bazvalue"
    end
  end

  context 'the file has quotation marks in its section names' do
    let(:sample_content) do
      template = <<-EOS
[branch "master"]
        remote = origin
        merge = refs/heads/master

[alias]
to-deploy = log --merges --grep='pull request' --format='%s (%cN)' origin/production..origin/master
[branch "production"]
        remote = origin
        merge = refs/heads/production
      EOS
      template.split("\n")
    end

    it 'should parse the sections' do
      subject.section_names.should match_array ['',
                                                'branch "master"',
                                                'alias',
                                                'branch "production"'
      ]
    end
  end

  context 'Samba INI file with dollars in section names' do
    let(:sample_content) do
      template = <<-EOS
      [global]
        workgroup = FELLOWSHIP
        ; ...
        idmap config * : backend = tdb

      [printers]
        comment = All Printers
        ; ...
        browseable = No

      [print$]
        comment = Printer Drivers
        path = /var/lib/samba/printers

      [Shares]
        path = /home/shares
        read only = No
        guest ok = Yes
      EOS
      template.split("\n")
    end

    it "should parse the correct section_names" do
      subject.section_names.should match_array [
        '',
        'global',
        'printers',
        'print$',
        'Shares'
      ]
    end
  end

  context 'section names with forward slashes in them' do
    let(:sample_content) do
      template = <<-EOS
[monitor:///var/log/*.log]
disabled = test_value
      EOS
      template.split("\n")
    end

    it "should parse the correct section_names" do
      subject.section_names.should match_array [
        '',
        'monitor:///var/log/*.log'
      ]
    end
  end
end
