require 'spec_helper'

describe 'postgresql::lib::perl', :type => :class do

  describe 'on a redhat based os' do
    let :facts do {
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
      :operatingsystemrelease => '6.4',
    }
    end
    it { is_expected.to contain_package('perl-DBD-Pg').with(
      :name => 'perl-DBD-Pg',
      :ensure => 'present'
    )}
  end

  describe 'on a debian based os' do
    let :facts do {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
    }
    end
    it { is_expected.to contain_package('perl-DBD-Pg').with(
      :name => 'libdbd-pg-perl',
      :ensure => 'present'
    )}
  end

end
