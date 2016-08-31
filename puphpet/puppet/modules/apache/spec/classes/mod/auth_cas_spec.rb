require 'spec_helper'

describe 'apache::mod::auth_cas', :type => :class do
  let :params do
    {
      :cas_login_url    => 'https://cas.example.com/login',
      :cas_validate_url => 'https://cas.example.com/validate',
    }
  end

  let :pre_condition do
    'include ::apache'
  end

  context "on a Debian OS", :compile do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :lsbdistcodename        => 'squeeze',
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '6',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :concat_basedir         => '/dne',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.to contain_apache__mod("auth_cas") }
    it { is_expected.to contain_package("libapache2-mod-auth-cas") }
    it { is_expected.to contain_file("auth_cas.conf").with_path('/etc/apache2/mods-available/auth_cas.conf') }
    it { is_expected.to contain_file("/var/cache/apache2/mod_auth_cas/").with_owner('www-data') }
  end
  context "on a RedHat OS", :compile do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :operatingsystemrelease => '6',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :concat_basedir         => '/dne',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.to contain_apache__mod("auth_cas") }
    it { is_expected.to contain_package("mod_auth_cas") }
    it { is_expected.to contain_file("auth_cas.conf").with_path('/etc/httpd/conf.d/auth_cas.conf') }
    it { is_expected.to contain_file("/var/cache/mod_auth_cas/").with_owner('apache') }
  end
end
