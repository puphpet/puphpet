class puphpet::postgresql (
  $postgresql = $puphpet::params::hiera['postgresql'],
  $apache     = $puphpet::params::hiera['apache'],
  $nginx      = $puphpet::params::hiera['nginx'],
  $php        = $puphpet::params::hiera['php'],
  $hhvm       = $puphpet::params::hiera['hhvm'],
) {

  include puphpet::apache::params
  include puphpet::nginx::params

  if array_true($apache, 'install') or array_true($nginx, 'install') {
    $webserver_restart = true
  } else {
    $webserver_restart = false
  }

  if array_true($php, 'install') {
    $php_package = 'php'
  } elsif array_true($hhvm, 'install') {
    $php_package = 'hhvm'
  } else {
    $php_package = false
  }

  if empty($postgresql['settings']['server']['postgres_password']) {
    fail( 'PostgreSQL requires choosing a root password.' )
  }

  Class['postgresql::globals']
  -> Class['postgresql::server']

  $global_settings = merge({
    'manage_package_repo' => true,
    'encoding'            => 'UTF8',
  }, $postgresql['settings']['global'])

  $server_settings = merge({
    'user'  => 'postgres',
    'group' => 'postgres',
  }, $postgresql['settings']['server'])

  create_resources('class', {
    'postgresql::globals' => $global_settings
  })

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

  each( $users ) |$key, $user| {
    $superuser = array_true($user, 'superuser') ? {
      true    => true,
      default => false,
    }

    $no_superuser = delete(merge({
      'password_hash' => postgresql_password($user['username'], $user['password']),
      'login'         => true,
    }, $user), 'password')

    $merged = merge($no_superuser, {
      'superuser' => $superuser,
    })

    create_resources( postgresql::server::role, {
      "${merged['username']}" => $merged
    })
  }

  # config file could contain no databases key
  $databases = array_true($postgresql, 'databases') ? {
    true    => $postgresql['databases'],
    default => { }
  }

  each( $databases ) |$key, $database| {
    $owner = array_true($database, 'owner') ? {
      true    => $database['owner'],
      default => $postgresql::server::user,
    }

    $merged = merge($database, {
      'owner' => $owner,
    })

    create_resources( postgresql::server::database, {
      "${owner}@${database['dbname']}" => $merged
    })
  }

  # config file could contain no grants key
  $grants = array_true($postgresql, 'grants') ? {
    true    => $postgresql['grants'],
    default => { }
  }

  each( $grants ) |$key, $grant| {
    $merged = merge($grant, {
      'privilege' => join($grant['privilege'], ','),
    })

    create_resources( postgresql::server::database_grant, {
      "${grant['role']}@${grant['db']}" => $merged,
    })
  }

  if $php_package == 'php' and ! defined(Puphpet::Php::Module['pgsql']) {
    puphpet::php::module { 'pgsql':
      service_autorestart => $webserver_restart,
    }
  }

  if array_true($mariadb, 'adminer')
    and $php_package
    and ! defined(Class['puphpet::adminer::install'])
  {
    class { 'puphpet::adminer::install': }
  }

}
