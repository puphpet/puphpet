# == Class: puphpet::postgresql::install
#
# Installs PostgreSql.
#
# Usage:
#
#  class { 'puphpet::postgresql::install': }
#
class puphpet::postgresql::install
 inherits puphpet::postgresql::params {

  include ::mysql::params

  $postgresql = $puphpet::params::hiera['postgresql']

  $settings = $postgresql['settings']

  Class['postgresql::globals']
  -> Class['postgresql::server']

  $global_settings = merge({
    'manage_package_repo' => true,
    'encoding'            => 'UTF8',
  }, $postgresql['settings']['global'])

  create_resources('class', {
    'postgresql::globals' => $global_settings
  })

  $server_settings = merge({
    'user'  => 'postgres',
    'group' => 'postgres',
  }, $postgresql['settings']['server'])

  create_resources('class', {
    'postgresql::server' => $server_settings
  })

  Postgresql::Server::Role <| |>
  -> Postgresql::Server::Database <| |>
  -> Postgresql::Server::Database_grant <| |>

  # config file could contain no users key
  $users = array_true($postgresql, 'users') ? {
    true    => $postgresql['users'],
    default => { }
  }

  puphpet::postgresql::users { 'from puphpet::postgresql::install':
    users => $users,
  }

  # config file could contain no databases key
  $databases = array_true($postgresql, 'databases') ? {
    true    => $postgresql['databases'],
    default => { }
  }

  puphpet::postgresql::databases { 'from puphpet::postgresql::install':
    databases => $databases,
  }

  # config file could contain no grants key
  $grants = array_true($postgresql, 'grants') ? {
    true    => $postgresql['grants'],
    default => { }
  }

  puphpet::postgresql::grants { 'from puphpet::postgresql::install':
    grants => $grants,
  }

}
