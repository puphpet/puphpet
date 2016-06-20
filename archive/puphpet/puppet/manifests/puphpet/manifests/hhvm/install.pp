# == Class: puphpet::hhvm::install
#
# Installs HHVM.
#
# Usage:
#
#  class { 'puphpet::hhvm::install': }
#
class puphpet::hhvm::install
  inherits puphpet::hhvm::params
{

  group { $puphpet::hhvm::params::group:
    ensure => present,
  }

  user { $puphpet::hhvm::params::user:
    ensure     => present,
    groups     => [$puphpet::hhvm::params::group],
    managehome => false,
    require    => Group[$puphpet::hhvm::params::group],
  }

  case $::lsbdistcodename {
    'wheezy': {
      class { 'puphpet::hhvm::repo::debian7':
        before => Package[$puphpet::hhvm::params::package_name],
      }
    }
    'precise': {
      class { 'puphpet::hhvm::repo::ubuntu1204':
        before => Package[$puphpet::hhvm::params::package_name],
      }
    }
    'trusty': {
      class { 'puphpet::hhvm::repo::ubuntu1404': }
      -> package { 'libdouble-conversion1':
        ensure => present,
      }
      -> package { 'liblz4-1':
        ensure => present,
        before => Package[$puphpet::hhvm::params::package_name],
      }
    }
    default: {
      fail('HHVM not supported on this distro')
    }
  }

  package { $puphpet::hhvm::params::package_name:
    ensure => present
  }

  service { $puphpet::hhvm::params::service_name:
    ensure  => 'running',
    require => [
      User[$puphpet::hhvm::params::user],
      Package[$puphpet::hhvm::params::package_name],
    ],
  }

  $override_php_alias = array_true($puphpet::params::hiera['hhvm']['settings'], 'override_php_alias') ? {
    true    => $puphpet::params::hiera['hhvm']['settings']['override_php_alias'],
    default => { }
  }

  if $override_php_alias {
    file { '/usr/bin/php':
      ensure  => 'link',
      target  => '/usr/bin/hhvm',
      require => Package[$puphpet::hhvm::params::package_name]
    }
  }

  if array_true($hhvm, 'composer') and ! defined(Class['puphpet::php::composer']) {
    class { 'puphpet::php::composer':
      php_package   => 'hhvm',
      composer_home => $hhvm['composer_home'],
    }
  }

}
