# == Class: puphpet::sqlite::install
#
# Installs SQLite.
#
# Usage:
#
#  class { 'puphpet::sqlite::install': }
#
class puphpet::sqlite::install
 inherits puphpet::sqlite::params {

  $sqlite = $puphpet::params::hiera['sqlite']

  $settings = $sqlite['settings']

  if ! defined(Package['sqlite']) {
    package { 'sqlite':
      ensure => installed,
    }
  }

  if ! defined(Group[$puphpet::sqlite::params::group]) {
    group { $puphpet::sqlite::params::group :
      ensure => present
    }
  }

  if ! defined(User[$puphpet::sqlite::params::user]) {
    user { $puphpet::sqlite::params::user :
      ensure     => present,
      managehome => false,
      groups     => $puphpet::sqlite::params::group,
      require    => Group[$puphpet::sqlite::params::group],
    }
  }

  if ! defined(File[$puphpet::sqlite::params::config_dir]) {
    file { $puphpet::sqlite::params::config_dir:
      ensure  => directory,
      owner   => $puphpet::sqlite::params::user,
      group   => $puphpet::sqlite::params::group,
      mode    => '0775',
      require => User[$puphpet::sqlite::params::user]
    }
  }

  # config file could contain no databases key
  $databases = array_true($sqlite, 'databases') ? {
    true    => $sqlite['databases'],
    default => { }
  }

  puphpet::sqlite::databases { 'from puphpet::sqlite::install':
    databases => $databases,
  }

  include puphpet::sqlite::php

}
