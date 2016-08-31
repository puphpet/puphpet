require 'spec_helper'

describe 'apache::mod::alias', :type => :class do
  let :pre_condition do
    'include apache'
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
    it { is_expected.to contain_apache__mod("alias") }
    it { is_expected.to contain_file("alias.conf").with(:content => /Alias \/icons\/ "\/usr\/share\/apache2\/icons\/"/) }
  end
  context "on a RedHat 6-based OS", :compile do
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
    it { is_expected.to contain_apache__mod("alias") }
    it { is_expected.to contain_file("alias.conf").with(:content => /Alias \/icons\/ "\/var\/www\/icons\/"/) }
  end
  context "on a RedHat 7-based OS", :compile do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :operatingsystemrelease => '7',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :concat_basedir         => '/dne',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_apache__mod("alias") }
    it { is_expected.to contain_file("alias.conf").with(:content => /Alias \/icons\/ "\/usr\/share\/httpd\/icons\/"/) }
  end
  context "with icons options", :compile do
    let :pre_condition do
      'class { apache: default_mods => false }'
    end
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :operatingsystemrelease => '7',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :concat_basedir         => '/dne',
        :is_pe                  => false,
      }
    end
    let :params do
      {
        'icons_options' => 'foo'
      }
    end
    it { is_expected.to contain_apache__mod("alias") }
    it { is_expected.to contain_file("alias.conf").with(:content => /Options foo/) }
  end
  context "on a FreeBSD OS", :compile do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'FreeBSD',
        :osfamily               => 'FreeBSD',
        :operatingsystem        => 'FreeBSD',
        :operatingsystemrelease => '10',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :concat_basedir         => '/dne',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_apache__mod("alias") }
    it { is_expected.to contain_file("alias.conf").with(:content => /Alias \/icons\/ "\/usr\/local\/www\/apache24\/icons\/"/) }
  end
end
