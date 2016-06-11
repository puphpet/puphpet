# This depends on
#   puppetlabs/apt: https://github.com/puppetlabs/puppetlabs-apt
#   example42/puppet-yum: https://github.com/example42/puppet-yum

class puphpet::php::repos (
  $php_version
){

  case $::operatingsystem {
    'debian': {
      # Squeeze: 5.3 (default) && 5.4
      if $::lsbdistcodename == 'squeeze' and $php_version == '54'
        and ! defined(Apt::Source['packages.dotdeb.org-php54-repo.puphpet']) {
       ::apt::source { 'packages.dotdeb.org-php54-repo.puphpet':
          location          => 'http://repo.puphpet.com/dotdeb/',
          release           => 'squeeze-php54',
          repos             => 'all',
          required_packages => 'debian-keyring debian-archive-keyring',
          key               => {
            'id'      => '89DF5277',
            'server'  => 'hkp://keyserver.ubuntu.com:80',
          },
          include           => { 'src' => true }
        }
      }
      # Wheezy : 5.4 (default) && 5.5 && 5.6
      elsif $::lsbdistcodename == 'wheezy' and $php_version == '55'
        and ! defined(Apt::Source['packages.dotdeb.org-php55-repo.puphpet']) {
       ::apt::source { 'packages.dotdeb.org-php55-repo.puphpet':
          location          => 'http://repo.puphpet.com/dotdeb/',
          release           => 'wheezy-php55',
          repos             => 'all',
          required_packages => 'debian-keyring debian-archive-keyring',
          key               => {
            'id'      => '89DF5277',
            'server'  => 'hkp://keyserver.ubuntu.com:80',
          },
          include           => { 'src' => true }
        }
      }
      elsif $::lsbdistcodename == 'wheezy' and $php_version == '56'
        and ! defined(Apt::Source['packages.dotdeb.org-php56-repo.puphpet']) {
       ::apt::source { 'packages.dotdeb.org-php56-repo.puphpet':
          location          => 'http://repo.puphpet.com/dotdeb/',
          release           => 'wheezy-php56',
          repos             => 'all',
          required_packages => 'debian-keyring debian-archive-keyring',
          key               => {
            'id'      => '89DF5277',
            'server'  => 'hkp://keyserver.ubuntu.com:80',
          },
          include           => { 'src' => true }
        }
      }
    }
    'ubuntu': {
      if ! defined(Apt::Key['14AA40EC0831756756D7F66C4F4EA0AAE5267A6C']) {
        ::apt::key { '14AA40EC0831756756D7F66C4F4EA0AAE5267A6C':
          server => 'hkp://keyserver.ubuntu.com:80'
        }
      }

      # Lucid 10.04, Precise 12.04, Quantal 12.10,
      # Raring 13.04: 5.3 (default <= 12.10) && 5.4 (default <= 13.04)
      if $::lsbdistcodename in ['lucid', 'precise', 'quantal', 'raring', 'trusty']
        and $php_version == '54' and ! defined(Apt::Source['ppa-ondrej-php5-oldstable'])
      {
        ::apt::pin { 'ppa-ondrej-php5-oldstable':
          priority   => 1000,
          originator => 'LP-PPA-ondrej-php5-oldstable',
        }

        ::apt::source { 'ppa-ondrej-php5-oldstable':
          comment  => 'ppa:ondrej/php5-oldstable',
          location => 'http://ppa.launchpad.net/ondrej/php5-oldstable/ubuntu',
          release  => 'precise',
          repos    => 'main',
          include  => {
            'src' => true,
            'deb' => true,
          },
          require  => Apt::Pin['ppa-ondrej-php5-oldstable'],
        }
      }
      # 12.04/10, 13.04/10, 14.04: 5.5
      elsif $::lsbdistcodename in ['precise', 'quantal', 'raring', 'saucy', 'trusty']
        and $php_version == '55' and ! defined(Apt::Ppa['ppa:ondrej/php5'])
      {
        ::apt::ppa { 'ppa:ondrej/php5':
          require => ::Apt::Key['14AA40EC0831756756D7F66C4F4EA0AAE5267A6C']
        }
      }
      elsif $::lsbdistcodename in ['lucid'] and $php_version == '55' {
        err('You have chosen to install PHP 5.5 on Ubuntu 10.04 Lucid. This will probably not work!')
      }
      # Ubuntu 14.04 can do PHP 5.6 and PHP 7
      elsif $::lsbdistcodename == 'trusty' and $php_version in ['56', '70']
        and ! defined(Apt::Ppa['ppa:ondrej/php']) {
        ::apt::ppa { 'ppa:ondrej/php':
          require => ::Apt::Key['14AA40EC0831756756D7F66C4F4EA0AAE5267A6C']
        }
      }
    }
    'redhat', 'centos': {
      if $php_version == '53' {
        $ius_gpg_key_url = 'https://dl.iuscommunity.org/pub/ius/IUS-COMMUNITY-GPG-KEY'
        $ius_gpg_key_dl  = '/etc/pki/rpm-gpg/IUS-COMMUNITY-GPG-KEY'

        exec { 'ius gpg key':
          command => "wget --quiet --tries=5 --connect-timeout=10 -O '${ius_gpg_key_dl}' ${ius_gpg_key_url}",
          creates => $ius_gpg_key_dl,
          path    => '/usr/bin:/bin',
        }

        ::yum::managed_yumrepo { 'ius6-archive':
          descr          => 'IUS Community Project Archive',
          mirrorlist     => 'http://dmirr.iuscommunity.org/mirrorlist/?repo=ius-el6-archive&arch=$basearch',
          enabled        => 1,
          gpgcheck       => 1,
          gpgkey         => "file://${ius_gpg_key_dl}",
          priority       => 1,
        }
      }

      if $php_version != '53' {
        include ::yum::repo::remi
      }

      # remi_php55 requires the remi repo as well
      if $php_version == '55' {
        include ::yum::repo::remi_php55
      }
      # remi_php56 requires the remi repo as well
      elsif $php_version == '56' {
        ::yum::managed_yumrepo { 'remi-php56':
          descr          => 'Les RPM de remi pour Enterpise Linux $releasever - $basearch - PHP 5.6',
          mirrorlist     => 'http://rpms.famillecollet.com/enterprise/$releasever/php56/mirror',
          enabled        => 1,
          gpgcheck       => 1,
          gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi',
          gpgkey_source  => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-remi',
          priority       => 1,
        }
      }
      # remi_php70 requires the remi repo as well
      elsif $php_version == '70' {
        ::yum::managed_yumrepo { 'remi-php70':
          descr          => 'Les RPM de remi pour Enterpise Linux $releasever - $basearch - PHP 7.0',
          mirrorlist     => 'http://rpms.famillecollet.com/enterprise/$releasever/php70/mirror',
          enabled        => 1,
          gpgcheck       => 1,
          gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi',
          gpgkey_source  => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-remi',
          priority       => 1,
        }
      }
    }
  }

}
