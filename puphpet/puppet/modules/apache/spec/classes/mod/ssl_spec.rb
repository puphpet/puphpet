require 'spec_helper'

describe 'apache::mod::ssl', :type => :class do
  let :pre_condition do
    'include apache'
  end
  context 'on an unsupported OS' do
    let :facts do
      {
        :osfamily               => 'Magic',
        :operatingsystemrelease => '0',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'Magic',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { expect { subject }.to raise_error(Puppet::Error, /Unsupported osfamily:/) }
  end

  context 'on a RedHat OS' do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'RedHat',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class('apache::params') }
    it { is_expected.to contain_apache__mod('ssl') }
    it { is_expected.to contain_package('mod_ssl') }
    context 'with a custom package_name parameter' do
      let :params do
        { :package_name => 'httpd24-mod_ssl' }
      end
      it { is_expected.to contain_class('apache::params') }
      it { is_expected.to contain_apache__mod('ssl') }
      it { is_expected.to contain_package('httpd24-mod_ssl') }
      it { is_expected.not_to contain_package('mod_ssl') }
    end
  end

  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :lsbdistcodename        => 'squeeze',
        :operatingsystem        => 'Debian',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class('apache::params') }
    it { is_expected.to contain_apache__mod('ssl') }
    it { is_expected.not_to contain_package('libapache2-mod-ssl') }
  end

  context 'on a FreeBSD OS' do
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
    it { is_expected.to contain_class('apache::params') }
    it { is_expected.to contain_apache__mod('ssl') }
  end

  context 'on a Gentoo OS' do
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
    it { is_expected.to contain_class('apache::params') }
    it { is_expected.to contain_apache__mod('ssl') }
  end

  # Template config doesn't vary by distro
  context "on all distros" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystem        => 'CentOS',
        :operatingsystemrelease => '6',
        :kernel                 => 'Linux',
        :id                     => 'root',
        :concat_basedir         => '/dne',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end

    context 'not setting ssl_pass_phrase_dialog' do
      it { is_expected.to contain_file('ssl.conf').with_content(/^  SSLPassPhraseDialog builtin$/)}
    end

    context 'setting ssl_pass_phrase_dialog' do
      let :params do
        {
          :ssl_pass_phrase_dialog => 'exec:/path/to/program',
        }
      end
      it { is_expected.to contain_file('ssl.conf').with_content(/^  SSLPassPhraseDialog exec:\/path\/to\/program$/)}
    end

    context 'setting ssl_random_seed_bytes' do
      let :params do
        {
          :ssl_random_seed_bytes => '1024',
        }
      end
      it { is_expected.to contain_file('ssl.conf').with_content(%r{^  SSLRandomSeed startup file:/dev/urandom 1024$})}
    end
  end
end
