require 'spec_helper'

describe 'apache::mod::prefork', :type => :class do
  let :pre_condition do
    'class { "apache": mpm_module => false, }'
  end
  context "on a Debian OS" do
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
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.not_to contain_apache__mod('prefork') }
    it { is_expected.to contain_file("/etc/apache2/mods-available/prefork.conf").with_ensure('file') }
    it { is_expected.to contain_file("/etc/apache2/mods-enabled/prefork.conf").with_ensure('link') }

    context "with Apache version < 2.4" do
      let :params do
        {
          :apache_version => '2.2',
        }
      end

      it { is_expected.not_to contain_file("/etc/apache2/mods-available/prefork.load") }
      it { is_expected.not_to contain_file("/etc/apache2/mods-enabled/prefork.load") }

      it { is_expected.to contain_package("apache2-mpm-prefork") }
    end

    context "with Apache version >= 2.4" do
      let :params do
        {
          :apache_version => '2.4',
        }
      end

      it { is_expected.to contain_file("/etc/apache2/mods-available/prefork.load").with({
        'ensure'  => 'file',
        'content' => "LoadModule mpm_prefork_module /usr/lib/apache2/modules/mod_mpm_prefork.so\n"
        })
      }
      it { is_expected.to contain_file("/etc/apache2/mods-enabled/prefork.load").with_ensure('link') }
    end
  end
  context "on a RedHat OS" do
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
    it { is_expected.not_to contain_apache__mod('prefork') }
    it { is_expected.to contain_file("/etc/httpd/conf.d/prefork.conf").with_ensure('file') }

    context "with Apache version < 2.4" do
      let :params do
        {
          :apache_version => '2.2',
        }
      end

      it { is_expected.to contain_file_line("/etc/sysconfig/httpd prefork enable").with({
        'require' => 'Package[httpd]',
        })
      }
    end

    context "with Apache version >= 2.4" do
      let :params do
        {
          :apache_version => '2.4',
        }
      end

      it { is_expected.not_to contain_apache__mod('event') }

      it { is_expected.to contain_file("/etc/httpd/conf.d/prefork.load").with({
        'ensure'  => 'file',
        'content' => "LoadModule mpm_prefork_module modules/mod_mpm_prefork.so\n",
        })
      }
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
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.not_to contain_apache__mod('prefork') }
    it { is_expected.to contain_file("/usr/local/etc/apache24/Modules/prefork.conf").with_ensure('file') }
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
    it { is_expected.not_to contain_apache__mod('prefork') }
    it { is_expected.to contain_file("/etc/apache2/modules.d/prefork.conf").with_ensure('file') }
  end
end
