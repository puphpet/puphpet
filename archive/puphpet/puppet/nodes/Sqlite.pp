if $sqlite_values == undef { $sqlite_values = hiera_hash('sqlite', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }
if $mailcatcher_values == undef { $mailcatcher_values = hiera_hash('mailcatcher', false) }

include puphpet::params
include puphpet::apache::params

# puppet manifests for mailcatcher and sqlite are not compatible.
if hash_key_equals($sqlite_values, 'install', 1)
  and hash_key_equals($mailcatcher_values, 'install', 0)
{
  if hash_key_equals($php_values, 'install', 1) {
    $sqlite_php_installed = true
    $sqlite_php_package   = 'php'
  } elsif hash_key_equals($hhvm_values, 'install', 1) {
    $sqlite_php_installed = true
    $sqlite_php_package   = 'hhvm'
  } else {
    $sqlite_php_installed = false
  }

  Class['Puphpet::Sqlite::Install']
  -> Puphpet::Sqlite::Db <| |>

  class { 'puphpet::sqlite::install': }

  # config file could contain no databases key
  $sqlite_databases = array_true($sqlite_values, 'databases') ? {
    true    => $sqlite_values['databases'],
    default => { }
  }

  each( $sqlite_databases ) |$key, $database| {
    $group = value_true($database['group']) ? {
      true    => $database['group'],
      default => 'sqlite'
    }

    $database_merged = delete(merge($database, {
      'group' => $group,
    }), 'mode')

    create_resources( puphpet::sqlite::db, { "${key}" => $database_merged })
  }

  if $sqlite_php_installed
    and $sqlite_php_package == 'php'
    and ! defined(Puphpet::Php::Pecl['sqlite'])
  {
    puphpet::php::pecl { 'sqlite':
      service_autorestart => true,
    }
  }

  if array_true($sqlite_values, 'adminer')
    and $sqlite_php_installed
    and ! defined(Class['puphpet::adminer'])
  {
    if hash_key_equals($apache_values, 'install', 1) {
      $sqlite_adminer_webroot = $puphpet::apache::params::default_vhost_dir
    } elsif hash_key_equals($nginx_values, 'install', 1) {
      $sqlite_adminer_webroot = $puphpet::params::nginx_webroot_location
    } else {
      $sqlite_adminer_webroot = $puphpet::apache::params::default_vhost_dir
    }

    class { 'puphpet::adminer':
      location    => "${sqlite_adminer_webroot}/adminer",
      owner       => 'www-data',
      php_package => $sqlite_php_package
    }
  }
}
