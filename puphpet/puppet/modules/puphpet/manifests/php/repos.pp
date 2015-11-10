# This depends on
#   puppetlabs/apt: https://github.com/puppetlabs/puppetlabs-apt
#   example42/puppet-yum: https://github.com/example42/puppet-yum

class puphpet::php::repos (
  $php_version
){

  case $::operatingsystem {
    'debian': {
      # Squeeze: 5.3 (default) && 5.4
      if $::lsbdistcodename == 'squeeze' and $php_version == '54' {
       ::apt::source { 'packages.dotdeb.org-php54-repo.puphpet':
          location          => 'http://repo.puphpet.com/dotdeb/',
          release           => 'squeeze-php54',
          repos             => 'all',
          required_packages => 'debian-keyring debian-archive-keyring',
          key               => '89DF5277',
          key_server        => 'keys.gnupg.net',
          include_src       => true
        }
      }
      # Wheezy : 5.4 (default) && 5.5 && 5.6
      elsif $::lsbdistcodename == 'wheezy' and $php_version == '55' {
       ::apt::source { 'packages.dotdeb.org-php55-repo.puphpet':
          location          => 'http://repo.puphpet.com/dotdeb/',
          release           => 'wheezy-php55',
          repos             => 'all',
          required_packages => 'debian-keyring debian-archive-keyring',
          key               => '89DF5277',
          key_server        => 'keys.gnupg.net',
          include_src       => true
        }
      }
      elsif $::lsbdistcodename == 'wheezy' and $php_version == '56' {
       ::apt::source { 'packages.dotdeb.org-php56-repo.puphpet':
          location          => 'http://repo.puphpet.com/dotdeb/',
          release           => 'wheezy-php56',
          repos             => 'all',
          required_packages => 'debian-keyring debian-archive-keyring',
          key               => '89DF5277',
          key_server        => 'keys.gnupg.net',
          include_src       => true
        }
      }
    }
    'ubuntu': {
      if ! defined(::Apt::Key['4F4EA0AAE5267A6C']) {
        ::apt::key { '4F4EA0AAE5267A6C':
          key_server => 'hkp://keyserver.ubuntu.com:80'
        }
      }

      # Lucid 10.04, Precise 12.04, Quantal 12.10,
      # Raring 13.04: 5.3 (default <= 12.10) && 5.4 (default <= 13.04)
      if $::lsbdistcodename in ['lucid', 'precise', 'quantal', 'raring', 'trusty']
        and $php_version == '54'
      {
        $options = $::lsbdistcodename ? {
          'lucid' => '',
          default => '-y'
        }

        ::apt::ppa { 'ppa:ondrej/php5-oldstable':
          require => ::Apt::Key['4F4EA0AAE5267A6C'],
          options => $options
        }
      }
      # 12.04/10, 13.04/10, 14.04: 5.5
      elsif $::lsbdistcodename in ['precise', 'quantal', 'raring', 'saucy', 'trusty']
        and $php_version == '55'
      {
        ::apt::ppa { 'ppa:ondrej/php5':
          require => ::Apt::Key['4F4EA0AAE5267A6C']
        }
      }
      elsif $::lsbdistcodename in ['lucid'] and $php_version == '55' {
        err('You have chosen to install PHP 5.5 on Ubuntu 10.04 Lucid. This will probably not work!')
      }
      # Ubuntu 14.04 can do PHP 5.6
      elsif $::lsbdistcodename == 'trusty' and $php_version == '56' {
        ::apt::ppa { 'ppa:ondrej/php5-5.6':
          require => ::Apt::Key['4F4EA0AAE5267A6C']
        }
      }
    }
    'redhat', 'centos': {
      include ::yum::repo::remi

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
    }
  }

}
