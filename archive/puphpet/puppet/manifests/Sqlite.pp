class puphpet_sqlite(
  $sqlite,
  $apache,
  $nginx,
  $php,
  $hhvm
) {

  include puphpet::apache::params

  if array_true($php, 'install') {
    $php_package = 'php'
  } elsif array_true($hhvm, 'install') {
    $php_package = 'hhvm'
  } else {
    $php_package = false
  }

  Class['Puphpet::Sqlite::Install']
  -> Puphpet::Sqlite::Db <| |>

  class { 'puphpet::sqlite::install': }

  # config file could contain no databases key
  $databases = array_true($sqlite, 'databases') ? {
    true    => $sqlite['databases'],
    default => { }
  }

  each( $databases ) |$key, $database| {
    $group = value_true($database['group']) ? {
      true    => $database['group'],
      default => 'sqlite'
    }

    $merged = delete(merge($database, {
      'group' => $group,
    }), 'mode')

    create_resources( puphpet::sqlite::db, { "${key}" => $merged })
  }

  if $php_package == 'php' and ! defined(Puphpet::Php::Pecl['sqlite']) {
    puphpet::php::pecl { 'sqlite':
      service_autorestart => true,
    }
  }

  if array_true($sqlite, 'adminer')
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
      location    => "${$adminer_webroot}/adminer",
      owner       => 'www-data',
      php_package => $php_package
    }
  }

}
