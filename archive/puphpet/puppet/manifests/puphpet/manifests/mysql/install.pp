# == Class: puphpet::mysql::install
#
# Installs MySQL.
#
# Usage:
#
#  class { 'puphpet::mysql::install': }
#
class puphpet::mysql::install
 inherits puphpet::mysql::params {

  include ::mysql::params

  $mysql = $puphpet::params::hiera['mysql']

  $settings = $mysql['settings']

  case $::osfamily {
    'debian': {
      class { 'puphpet::mysql::repo::debian':
        version => $settings['version'],
      }
    }
    'redhat': {
      class { 'puphpet::mysql::repo::centos':
        version => $settings['version'],
      }
    }
  }

  create_resources('class', {
    'puphpet::mysql::server' => $settings
  })

  class { 'mysql::client':
    package_name => $puphpet::mysql::params::client_package,
    require      => Class['puphpet::mysql::repo'],
  }

  Mysql_user <| |>
  -> Mysql_database <| |>
  -> Mysql_grant <| |>

  # config file could contain no users key
  $users = array_true($mysql, 'users') ? {
    true    => $mysql['users'],
    default => { }
  }

  puphpet::mysql::users { 'from puphpet::mysql::install':
    users => $users,
  }

  # config file could contain no databases key
  $databases = array_true($mysql, 'databases') ? {
    true    => $mysql['databases'],
    default => { }
  }

  puphpet::mysql::databases { 'from puphpet::mysql::install':
    databases => $databases,
  }

  # config file could contain no grants key
  $grants = array_true($mysql, 'grants') ? {
    true    => $mysql['grants'],
    default => { }
  }

  puphpet::mysql::grants { 'from puphpet::mysql::install':
    grants => $grants,
  }

  include puphpet::mysql::php

}
