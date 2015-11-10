require 'spec_helper'

describe 'apache::mod::dir', :type => :class do
  let :pre_condition do
    'class { "apache":
      default_mods => false,
    }'
  end
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'Debian',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :lsbdistcodename        => 'squeeze',
        :is_pe                  => false,
      }
    end
    context "passing no parameters" do
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_apache__mod('dir') }
      it { is_expected.to contain_file('dir.conf').with_content(/^DirectoryIndex /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.html /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.html\.var /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.cgi /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.pl /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.php /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.xhtml$/) }
    end
    context "passing indexes => ['example.txt','fearsome.aspx']" do
      let :params do
        {:indexes => ['example.txt','fearsome.aspx']}
      end
      it { is_expected.to contain_file('dir.conf').with_content(/ example\.txt /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ fearsome\.aspx$/) }
    end
  end
  context "on a RedHat OS" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'Redhat',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    context "passing no parameters" do
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_apache__mod('dir') }
      it { is_expected.to contain_file('dir.conf').with_content(/^DirectoryIndex /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.html /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.html\.var /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.cgi /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.pl /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.php /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.xhtml$/) }
    end
    context "passing indexes => ['example.txt','fearsome.aspx']" do
      let :params do
        {:indexes => ['example.txt','fearsome.aspx']}
      end
      it { is_expected.to contain_file('dir.conf').with_content(/ example\.txt /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ fearsome\.aspx$/) }
    end
  end
  context "on a FreeBSD OS" do
    let :facts do
      {
        :osfamily               => 'FreeBSD',
        :operatingsystemrelease => '9',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'FreeBSD',
        :id                     => 'root',
        :kernel                 => 'FreeBSD',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    context "passing no parameters" do
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_apache__mod('dir') }
      it { is_expected.to contain_file('dir.conf').with_content(/^DirectoryIndex /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.html /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.html\.var /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.cgi /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.pl /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.php /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.xhtml$/) }
    end
    context "passing indexes => ['example.txt','fearsome.aspx']" do
      let :params do
        {:indexes => ['example.txt','fearsome.aspx']}
      end
      it { is_expected.to contain_file('dir.conf').with_content(/ example\.txt /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ fearsome\.aspx$/) }
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
    context "passing no parameters" do
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_apache__mod('dir') }
      it { is_expected.to contain_file('dir.conf').with_content(/^DirectoryIndex /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.html /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.html\.var /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.cgi /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.pl /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.php /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ index\.xhtml$/) }
    end
    context "passing indexes => ['example.txt','fearsome.aspx']" do
      let :params do
        {:indexes => ['example.txt','fearsome.aspx']}
      end
      it { is_expected.to contain_file('dir.conf').with_content(/ example\.txt /) }
      it { is_expected.to contain_file('dir.conf').with_content(/ fearsome\.aspx$/) }
    end
  end
end
