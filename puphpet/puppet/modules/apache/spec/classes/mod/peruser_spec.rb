require 'spec_helper'

describe 'apache::mod::peruser', :type => :class do
  let :pre_condition do
    'class { "apache": mpm_module => false, }'
  end
  context "on a FreeBSD OS" do
    let :facts do
      {
        :osfamily               => 'FreeBSD',
        :operatingsystemrelease => '10',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'FreeBSD',
        :id                     => 'root',
        :kernel                 => 'FreeBSD',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /Unsupported osfamily FreeBSD/)
    end
  end
  context "on a Gentoo OS" do
    let :facts do
      {
        :osfamily               => 'Gentoo',
        :operatingsystem        => 'Gentoo',
        :operatingsystemrelease => '3.16.1-gentoo',
        :concat_basedir         => '/dne',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.not_to contain_apache__mod('peruser') }
    it { is_expected.to contain_file("/etc/apache2/modules.d/peruser.conf").with_ensure('file') }
  end
end
