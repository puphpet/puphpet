if $postgresql_values == undef { $postgresql_values = hiera_hash('postgresql', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }

include puphpet::params
include puphpet::apache::params

if hash_key_equals($postgresql_values, 'install', 1) {
  if hash_key_equals($apache_values, 'install', 1)
    or hash_key_equals($nginx_values, 'install', 1)
  {
    $postgresql_webserver_restart = true
  } else {
    $postgresql_webserver_restart = false
  }

  if hash_key_equals($php_values, 'install', 1) {
    $postgresql_php_installed = true
    $postgresql_php_package   = 'php'
  } elsif hash_key_equals($hhvm_values, 'install', 1) {
    $postgresql_php_installed = true
    $postgresql_php_package   = 'hhvm'
  } else {
    $postgresql_php_installed = false
  }

  if empty($postgresql_values['settings']['server']['postgres_password']) {
    fail( 'PostgreSQL requires choosing a root password. Please check your config.yaml file.' )
  }

  Class['postgresql::globals']
  -> Class['postgresql::server']

  $postgresql_settings_global = merge({
    'manage_package_repo' => true,
    'encoding'            => 'UTF8',
  }, $postgresql_values['settings']['global'])

  $postgresql_settings_server = merge({
    'user'  => 'postgres',
    'group' => 'postgres',
  }, $postgresql_values['settings']['server'])

  create_resources('class', {
    'postgresql::globals' => $postgresql_settings_global
  })

  create_resources('class', {
    'postgresql::server' => $postgresql_settings_server
  })

  Postgresql::Server::Role <| |>
  -> Postgresql::Server::Database <| |>
  -> Postgresql::Server::Database_grant <| |>

  # config file could contain no users key
  $postgresql_users = array_true($postgresql_values, 'users') ? {
    true    => $postgresql_values['users'],
    default => { }
  }

  each( $postgresql_users ) |$key, $user| {
    $superuser = array_true($user, 'superuser') ? {
      true    => true,
      default => false,
    }

    $user_no_superuser = delete(merge({
      'password_hash' => postgresql_password($user['username'], $user['password']),
      'login'         => true,
    }, $user), 'password')

    $user_merged = merge($user_no_superuser, {
      'superuser' => $superuser,
    })

    create_resources( postgresql::server::role, {
      "${user_merged['username']}" => $user_merged
    })
  }

  # config file could contain no databases key
  $postgresql_databases = array_true($postgresql_values, 'databases') ? {
    true    => $postgresql_values['databases'],
    default => { }
  }

  each( $postgresql_databases ) |$key, $database| {
    $owner = array_true($database, 'owner') ? {
      true    => $database['owner'],
      default => $postgresql::server::user,
    }

    $database_merged = merge($database, {
      'owner' => $owner,
    })

    create_resources( postgresql::server::database, {
      "${owner}@${database['dbname']}" => $database_merged
    })
  }

  # config file could contain no grants key
  $postgresql_grants = array_true($postgresql_values, 'grants') ? {
    true    => $postgresql_values['grants'],
    default => { }
  }

  each( $postgresql_grants ) |$key, $grant| {
    $grant_merged = merge($grant, {
      'privilege' => join($grant['privilege'], ','),
    })

    create_resources( postgresql::server::database_grant, {
      "${grant['role']}@${grant['db']}" => $grant_merged,
    })
  }

  if $postgresql_php_installed
    and $postgresql_php_package == 'php'
    and ! defined(Puphpet::Php::Module['pgsql'])
  {
    puphpet::php::module { 'pgsql':
      service_autorestart => $postgresql_webserver_restart,
    }
  }

  if hash_key_equals($postgresql_values, 'adminer', 1)
    and $postgresql_php_installed
  {
    $postgre_apache_webroot = $puphpet::apache::params::default_vhost_dir
    $postgre_nginx_webroot = $puphpet::params::nginx_webroot_location

    if hash_key_equals($apache_values, 'install', 1) {
      $postgresql_adminer_webroot_location = $postgre_apache_webroot
    } elsif hash_key_equals($nginx_values, 'install', 1) {
      $nginx_webroot = $puphpet::params::nginx_webroot_location
      $postgresql_adminer_webroot_location = $postgre_nginx_webroot
    } else {
      $postgresql_adminer_webroot_location = $postgre_apache_webroot
    }

    class { 'puphpet::adminer':
      location    => "${postgresql_adminer_webroot_location}/adminer",
      owner       => 'www-data',
      php_package => $postgresql_php_package
    }
  }
}
