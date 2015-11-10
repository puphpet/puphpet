require 'spec_helper'

describe 'apt_has_updates fact' do
  subject { Facter.fact(:apt_has_updates).value }
  after(:each) { Facter.clear }

  describe 'on non-Debian distro' do
    before {
      Facter.fact(:osfamily).expects(:value).at_least(1).returns 'RedHat'
    }
    it { should be_nil }
  end

  describe 'on Debian based distro missing update-notifier-common' do
    before {
      Facter.fact(:osfamily).expects(:value).at_least(1).returns 'Debian'
      File.stubs(:executable?) # Stub all other calls
      File.expects(:executable?).with('/usr/lib/update-notifier/apt-check').returns false
    }
    it { should be_nil }
  end

  describe 'on Debian based distro with broken packages' do
    before {
      Facter.fact(:osfamily).expects(:value).at_least(1).returns 'Debian'
      File.stubs(:executable?) # Stub all other calls
      Facter::Util::Resolution.stubs(:exec) # Catch all other calls
      File.expects(:executable?).with('/usr/lib/update-notifier/apt-check').returns true
      Facter::Util::Resolution.expects(:exec).with('/usr/lib/update-notifier/apt-check 2>&1').returns "E: Error: BrokenCount > 0"
    }
    it { should be_nil }
  end

  describe 'on Debian based distro with unknown error with semicolons' do
    before {
      Facter.fact(:osfamily).expects(:value).at_least(1).returns 'Debian'
      File.stubs(:executable?) # Stub all other calls
      Facter::Util::Resolution.stubs(:exec) # Catch all other calls
      File.expects(:executable?).with('/usr/lib/update-notifier/apt-check').returns true
      Facter::Util::Resolution.expects(:exec).with('/usr/lib/update-notifier/apt-check 2>&1').returns "E: Unknown Error: 'This error contains something that could be parsed like 4;3' (10)"
    }
    it { should be_nil }
  end

  describe 'on Debian based distro' do
    before {
      Facter.fact(:osfamily).expects(:value).at_least(1).returns 'Debian'
      File.stubs(:executable?) # Stub all other calls
      Facter::Util::Resolution.stubs(:exec) # Catch all other calls
      File.expects(:executable?).with('/usr/lib/update-notifier/apt-check').returns true
      Facter::Util::Resolution.expects(:exec).with('/usr/lib/update-notifier/apt-check 2>&1').returns "4;3"
    }
    it { should be true }
  end
end

