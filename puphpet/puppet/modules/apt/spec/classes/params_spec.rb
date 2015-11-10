require 'spec_helper'
describe 'apt::params', :type => :class do
  let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian' } }
  let (:title) { 'my_package' }

  it { should contain_apt__params }

  # There are 4 resources in this class currently
  # there should not be any more resources because it is a params class
  # The resources are class[apt::params], class[main], class[settings], stage[main]
  it "Should not contain any resources" do
    subject.resources.size.should == 4
  end

  describe "With unknown lsbdistid" do

    let(:facts) { { :lsbdistid => 'CentOS' } }
    let (:title) { 'my_package' }

    it do
      expect {
       should compile
      }.to raise_error(Puppet::Error, /Unsupported lsbdistid/)
    end

  end

  describe "With lsb-release not installed" do
    let(:facts) { { :lsbdistid => '' } }
    let (:title) { 'my_package' }

    it do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /Unable to determine lsbdistid, is lsb-release installed/)
    end
  end

end
