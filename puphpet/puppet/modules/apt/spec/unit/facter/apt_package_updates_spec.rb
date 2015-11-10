require 'spec_helper'

describe 'apt_package_updates fact' do
  subject { Facter.fact(:apt_package_updates).value }
  after(:each) { Facter.clear }

  describe 'when apt has no updates' do
    before { 
      Facter.fact(:apt_has_updates).stubs(:value).returns false
    }
    it { should be nil }
  end

  describe 'when apt has updates' do
    before { 
      Facter.fact(:osfamily).stubs(:value).returns 'Debian'
      File.stubs(:executable?) # Stub all other calls
      Facter::Util::Resolution.stubs(:exec) # Catch all other calls
      File.expects(:executable?).with('/usr/lib/update-notifier/apt-check').returns true
      Facter::Util::Resolution.expects(:exec).with('/usr/lib/update-notifier/apt-check 2>&1').returns "1;2"
      Facter::Util::Resolution.expects(:exec).with('/usr/lib/update-notifier/apt-check -p 2>&1').returns "puppet-common\nlinux-generic\nlinux-image-generic"
    }
    it {
      if Facter.version < '2.0.0'
        should == 'puppet-common,linux-generic,linux-image-generic'
      else
        should == ['puppet-common', 'linux-generic', 'linux-image-generic']
      end
    }
  end
end
