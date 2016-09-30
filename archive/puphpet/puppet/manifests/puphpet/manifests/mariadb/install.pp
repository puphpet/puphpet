# == Class: puphpet::mariadb::install
#
# Installs MariaDB.
#
# Usage:
#
#  class { 'puphpet::mariadb::install': }
#
class puphpet::mariadb::install
 inherits puphpet::mariadb::params {

  include ::puphpet::mysql::params
  include ::mysql::params

  $mariadb = $puphpet::mariadb::params::mariadb

  $settings = $mariadb['settings']

  case $::osfamily {
    'debian': {
      class { 'puphpet::mariadb::repo::debian':
        version => to_string($settings['version']),
      }
    }
    'redhat': {
      class { 'puphpet::mariadb::repo::centos':
        version => to_string($settings['version']),
      }
    }
  }

  class { 'puphpet::mariadb::server':
    settings => $settings,
  }

  class { 'mysql::client':
    package_name => $puphpet::mariadb::params::package_client_name,
  }

  if ! defined(User[$puphpet::mariadb::params::user]) {
    user { $puphpet::mariadb::params::user:
      ensure => present,
    }
  }

  if ! defined(Group[$::mysql::params::root_group]) {
    group { $::mysql::params::root_group:
      ensure => present,
    }
  }

  Mysql_user <| |>
  -> Mysql_database <| |>
  -> Mysql_grant <| |>

  # config file could contain no users key
  $users = array_true($mariadb, 'users') ? {
    true    => $mariadb['users'],
    default => { }
  }

  puphpet::mariadb::users { 'from puphpet::mariadb::install':
    users => $users,
  }

  # config file could contain no databases key
  $databases = array_true($mariadb, 'databases') ? {
    true    => $mariadb['databases'],
    default => { }
  }

  puphpet::mariadb::databases { 'from puphpet::mariadb::install':
    databases => $databases,
  }

  # config file could contain no grants key
  $grants = array_true($mariadb, 'grants') ? {
    true    => $mariadb['grants'],
    default => { }
  }

  puphpet::mariadb::grants { 'from puphpet::mariadb::install':
    grants => $grants,
  }

  include puphpet::mariadb::php

}
