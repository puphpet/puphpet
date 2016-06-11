class puphpet::sqlite(
  $sqlite = $puphpet::params::config['sqlite'],
  $apache = $puphpet::params::config['apache'],
  $nginx  = $puphpet::params::config['nginx'],
  $php    = $puphpet::params::config['php'],
  $hhvm   = $puphpet::params::config['hhvm'],
) {

  include puphpet::apache::params
  include puphpet::nginx::params

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

    create_resources( puphpet::sqlite::db, {
      "${name}" => $merged
    })
  }

  case $::operatingsystem {
    'debian': {
      $php_sqlite = 'sqlite'
    }
    'ubuntu': {
      $php_sqlite = 'sqlite3'
    }
    'redhat', 'centos': {
      $php_sqlite = 'sqlite3'
    }
  }

  if $php_package == 'php' and ! defined(Puphpet::Php::Module[$php_sqlite]) {
    puphpet::php::module { $php_sqlite:
      service_autorestart => true,
    }
  }

  if array_true($mariadb, 'adminer')
    and $php_package
    and ! defined(Class['puphpet::adminer'])
  {
    class { 'puphpet::adminer': }
  }

}
