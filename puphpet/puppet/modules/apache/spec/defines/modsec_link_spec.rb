require 'spec_helper'

describe 'apache::security::rule_link', :type => :define do
  let :pre_condition do
    'class { "apache": }
    class { "apache::mod::security": activated_rules => [] }
    '
  end

  let :title do
    'base_rules/modsecurity_35_bad_robots.data'
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
    it { should contain_file('modsecurity_35_bad_robots.data').with(
      :path => '/etc/httpd/modsecurity.d/activated_rules/modsecurity_35_bad_robots.data',
      :target => '/usr/lib/modsecurity.d/base_rules/modsecurity_35_bad_robots.data'
    ) }
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
    it { should contain_file('modsecurity_35_bad_robots.data').with(
      :path => '/etc/modsecurity/activated_rules/modsecurity_35_bad_robots.data',
      :target => '/usr/share/modsecurity-crs/base_rules/modsecurity_35_bad_robots.data'
    ) }
  end

end
