require 'spec_helper'

describe 'apt_update_last_success fact' do
  subject { Facter.fact(:apt_update_last_success).value }
  after(:each) { Facter.clear }

  describe 'on Debian based distro which has not yet created the update-success-stamp file' do
    before {
      Facter.fact(:osfamily).stubs(:value).returns 'Debian'
      File.stubs(:exists?).returns false
    }
    it 'should have a value of -1' do
      should == -1
    end
  end

  describe 'on Debian based distro which has created the update-success-stamp' do
    before {
      Facter.fact(:osfamily).stubs(:value).returns 'Debian'
      File.stubs(:exists?).returns true
      File.stubs(:mtime).returns 1407660561
    }
    it 'should have the value of the mtime of the file' do
      should == 1407660561
    end
  end

end
