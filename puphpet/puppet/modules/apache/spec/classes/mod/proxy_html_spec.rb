require 'spec_helper'

describe 'apache::mod::proxy_html', :type => :class do
  let :pre_condition do
    [
      'include apache',
      'include apache::mod::proxy',
      'include apache::mod::proxy_http',
    ]
  end
  context "on a Debian OS" do
    shared_examples "debian" do |loadfiles|
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_apache__mod('proxy_html').with(:loadfiles => loadfiles) }
      it { is_expected.to contain_package("libapache2-mod-proxy-html") }
    end
    let :facts do
      {
        :osfamily        => 'Debian',
        :concat_basedir  => '/dne',
        :architecture    => 'i386',
        :lsbdistcodename => 'squeeze',
        :operatingsystem => 'Debian',
        :id              => 'root',
        :kernel          => 'Linux',
        :path            => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :hardwaremodel   => 'i386',
        :is_pe                  => false,
      }
    end

    context "on squeeze" do
      let(:facts) { super().merge({ :operatingsystemrelease => '6' }) }
      it_behaves_like "debian", ['/usr/lib/libxml2.so.2']
    end
    context "on wheezy" do
      let(:facts) { super().merge({ :operatingsystemrelease => '7' }) }
      context "i386" do
        let(:facts) { super().merge({
          :hardwaremodel => 'i686',
          :architecture  => 'i386'
        })}
        it_behaves_like "debian", ["/usr/lib/i386-linux-gnu/libxml2.so.2"]
      end
      context "x64" do
        let(:facts) { super().merge({
          :hardwaremodel => 'x86_64',
          :architecture  => 'amd64'
        })}
        it_behaves_like "debian", ["/usr/lib/x86_64-linux-gnu/libxml2.so.2"]
      end
    end
  end
  context "on a RedHat OS", :compile do
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
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.to contain_apache__mod('proxy_html').with(:loadfiles => nil) }
    it { is_expected.to contain_package("mod_proxy_html") }
  end
  context "on a FreeBSD OS", :compile do
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
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.to contain_apache__mod('proxy_html').with(:loadfiles => nil) }
    it { is_expected.to contain_package("www/mod_proxy_html") }
  end
  context "on a Gentoo OS", :compile do
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
    it { is_expected.to contain_apache__mod('proxy_html').with(:loadfiles => nil) }
    it { is_expected.to contain_package("www-apache/mod_proxy_html") }
  end
end
