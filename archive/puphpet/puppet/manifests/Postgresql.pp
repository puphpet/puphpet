class puphpet_postgresql (
  $postgresql,
  $apache,
  $nginx,
  $php,
  $hhvm
) {

  include puphpet::apache::params

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

  if array_true($postgresql, 'adminer')
    and $php_package
    and ! defined(Class['puphpet::adminer'])
  {
    $apache_webroot = $puphpet::apache::params::default_vhost_dir
    $nginx_webroot  = $puphpet::params::nginx_webroot_location

    if array_true($apache, 'install') {
      $adminer_webroot = $apache_webroot
      Class['puphpet_apache']
      -> Class['puphpet::adminer']
    } elsif array_true($nginx, 'install') {
      $adminer_webroot = $nginx_webroot
      Class['puphpet_nginx']
      -> Class['puphpet::adminer']
    } else {
      fail( 'Adminer requires either Apache or Nginx to be installed.' )
    }

    class { 'puphpet::adminer':
      location => "${$adminer_webroot}/adminer",
      owner    => 'www-data',
    }
  }

}
