require 'spec_helper'

describe 'apache::mod::security', :type => :class do
  let :pre_condition do
    'include apache'
  end

  context "on RedHat based systems" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystem        => 'CentOS',
        :operatingsystemrelease => '7',
        :kernel                 => 'Linux',
        :id                     => 'root',
        :concat_basedir         => '/',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { should contain_apache__mod('security').with(
      :id => 'security2_module',
      :lib => 'mod_security2.so'
    ) }
    it { should contain_apache__mod('unique_id_module').with(
      :id => 'unique_id_module',
      :lib => 'mod_unique_id.so'
    ) }
    it { should contain_package('mod_security_crs') }
    it { should contain_file('security.conf').with(
      :path => '/etc/httpd/conf.d/security.conf'
    ) }
    it { should contain_file('/etc/httpd/modsecurity.d').with(
      :ensure => 'directory',
      :path => '/etc/httpd/modsecurity.d',
      :owner => 'apache',
      :group => 'apache'
    ) }
    it { should contain_file('/etc/httpd/modsecurity.d/activated_rules').with(
      :ensure => 'directory',
      :path => '/etc/httpd/modsecurity.d/activated_rules',
      :owner => 'apache',
      :group => 'apache'
    ) }
    it { should contain_file('/etc/httpd/modsecurity.d/security_crs.conf').with(
      :path => '/etc/httpd/modsecurity.d/security_crs.conf'
    ) }
    it { should contain_apache__security__rule_link('base_rules/modsecurity_35_bad_robots.data') }
  end

  context "on Debian based systems" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/',
        :lsbdistcodename        => 'squeeze',
        :id                     => 'root',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :kernel                 => 'Linux',
        :is_pe                  => false,
      }
    end
    it { should contain_apache__mod('security').with(
      :id => 'security2_module',
      :lib => 'mod_security2.so'
    ) }
    it { should contain_apache__mod('unique_id_module').with(
      :id => 'unique_id_module',
      :lib => 'mod_unique_id.so'
    ) }
    it { should contain_package('modsecurity-crs') }
    it { should contain_file('security.conf').with(
      :path => '/etc/apache2/mods-available/security.conf'
    ) }
    it { should contain_file('/etc/modsecurity').with(
      :ensure => 'directory',
      :path => '/etc/modsecurity',
      :owner => 'www-data',
      :group => 'www-data'
    ) }
    it { should contain_file('/etc/modsecurity/activated_rules').with(
      :ensure => 'directory',
      :path => '/etc/modsecurity/activated_rules',
      :owner => 'www-data',
      :group => 'www-data'
    ) }
    it { should contain_file('/etc/modsecurity/security_crs.conf').with(
      :path => '/etc/modsecurity/security_crs.conf'
    ) }
    it { should contain_apache__security__rule_link('base_rules/modsecurity_35_bad_robots.data') }
  end

end
