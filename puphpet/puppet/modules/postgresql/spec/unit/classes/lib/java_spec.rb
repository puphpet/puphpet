require 'spec_helper'

describe 'postgresql::lib::java', :type => :class do

  describe 'on a debian based os' do
    let :facts do {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
    }
    end
    it { is_expected.to contain_package('postgresql-jdbc').with(
      :name   => 'libpostgresql-jdbc-java',
      :ensure => 'present',
      :tag    => 'postgresql'
    )}
  end

  describe 'on a redhat based os' do
    let :facts do {
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
      :operatingsystemrelease => '6.4',
    }
    end
    it { is_expected.to contain_package('postgresql-jdbc').with(
      :name => 'postgresql-jdbc',
      :ensure => 'present',
      :tag    => 'postgresql'
    )}
    describe 'when parameters are supplied' do
      let :params do
        {:package_ensure => 'latest', :package_name => 'somepackage'}
      end
      it { is_expected.to contain_package('postgresql-jdbc').with(
        :name => 'somepackage',
        :ensure => 'latest',
        :tag    => 'postgresql'
      )}
    end
  end

end
