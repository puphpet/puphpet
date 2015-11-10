require 'spec_helper'

describe 'apache::mod::fcgid', :type => :class do
  let :pre_condition do
    'include apache'
  end

  context "on a Debian OS" do
    let :facts do
      {
        :osfamily                  => 'Debian',
        :operatingsystemrelease    => '6',
        :operatingsystemmajrelease => '6',
        :concat_basedir            => '/dne',
        :lsbdistcodename           => 'squeeze',
        :operatingsystem           => 'Debian',
        :id                        => 'root',
        :kernel                    => 'Linux',
        :path                      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.to contain_apache__mod('fcgid') }
    it { is_expected.to contain_package("libapache2-mod-fcgid") }
  end

  context "on a RedHat OS" do
    let :facts do
      {
        :osfamily                  => 'RedHat',
        :operatingsystemrelease    => '6',
        :operatingsystemmajrelease => '6',
        :concat_basedir            => '/dne',
        :operatingsystem           => 'RedHat',
        :id                        => 'root',
        :kernel                    => 'Linux',
        :path                      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end

    describe 'without parameters' do
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_apache__mod('fcgid') }
      it { is_expected.to contain_package("mod_fcgid") }
    end

    describe 'with parameters' do
      let :params do {
        :options                     => {
          'FcgidIPCDir'               => '/var/run/fcgidsock',
          'SharememPath'              => '/var/run/fcgid_shm',
          'FcgidMinProcessesPerClass' => '0',
          'AddHandler'                => 'fcgid-script .fcgi',
        }
      } end

      it 'should contain the correct config' do
        content = subject.resource('file', 'fcgid.conf').send(:parameters)[:content]
        expect(content.split("\n").reject { |c| c =~ /(^#|^$)/ }).to eq([
          '<IfModule mod_fcgid.c>',
          '  AddHandler fcgid-script .fcgi',
          '  FcgidIPCDir /var/run/fcgidsock',
          '  FcgidMinProcessesPerClass 0',
          '  SharememPath /var/run/fcgid_shm',
          '</IfModule>',
        ])
      end
    end
  end

  context "on RHEL7" do
    let :facts do
      {
        :osfamily                  => 'RedHat',
        :operatingsystemrelease    => '7',
        :operatingsystemmajrelease => '7',
        :concat_basedir            => '/dne',
        :operatingsystem           => 'RedHat',
        :id                        => 'root',
        :kernel                    => 'Linux',
        :path                      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end

    describe 'without parameters' do
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_apache__mod('fcgid').with({
        'loadfile_name' => 'unixd_fcgid.load'
      })
      }
      it { is_expected.to contain_package("mod_fcgid") }
    end
  end

  context "on a FreeBSD OS" do
    let :facts do
      {
        :osfamily                  => 'FreeBSD',
        :operatingsystemrelease    => '9',
        :operatingsystemmajrelease => '9',
        :concat_basedir            => '/dne',
        :operatingsystem           => 'FreeBSD',
        :id                        => 'root',
        :kernel                    => 'FreeBSD',
        :path                      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end

    it { is_expected.to contain_class("apache::params") }
    it { is_expected.to contain_apache__mod('fcgid') }
    it { is_expected.to contain_package("www/mod_fcgid") }
  end

  context "on a Gentoo OS" do
    let :facts do
      {
        :osfamily                  => 'Gentoo',
        :operatingsystem           => 'Gentoo',
        :operatingsystemrelease    => '3.16.1-gentoo',
        :concat_basedir            => '/dne',
        :id                        => 'root',
        :kernel                    => 'Linux',
        :path                      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin',
        :is_pe                  => false,
      }
    end

    it { is_expected.to contain_class("apache::params") }
    it { is_expected.to contain_apache__mod('fcgid') }
    it { is_expected.to contain_package("www-apache/mod_fcgid") }
  end
end
