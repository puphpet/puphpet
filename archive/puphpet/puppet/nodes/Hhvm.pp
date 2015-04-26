if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }

include puphpet::params

if hash_key_equals($hhvm_values, 'install', 1) {
  class { 'puphpet::hhvm':
    nightly => $hhvm_values['nightly'],
  }

  if ! defined(Group['hhvm']) {
    group { 'hhvm':
      ensure => present,
    }
  }

  if ! defined(User['hhvm']) {
    user { 'hhvm':
      ensure     => present,
      home       => '/home/hhvm',
      groups     => ['hhvm', 'www-data'],
      managehome => true,
      require    => [
        Group['hhvm'],
        Group['www-data']
      ]
    }
  }

  User <| title == 'www-data' |> {
    groups  +> 'hhvm',
    require +> Group['hhvm'],
  }

  file { '/usr/bin/php':
    ensure  => 'link',
    target  => '/usr/bin/hhvm',
    require => Package['hhvm']
  }

  service { 'hhvm':
    ensure  => 'running',
    require => [
      User['hhvm'],
      Package['hhvm'],
    ],
  }

  $hhvm_server_ini_file = '/etc/hhvm/php.ini'

  # config file could contain no server_ini key
  $hhvm_server_inis = array_true($hhvm_values, 'server_ini') ? {
    true    => $hhvm_values['server_ini'],
    default => { }
  }

  each( $hhvm_server_inis ) |$key, $value| {
    $changes = [ "set '${key}' '${value}'" ]

    augeas { "${key}: ${value}":
      lens    => 'PHP.lns',
      incl    => $hhvm_server_ini_file,
      context => "/files${hhvm_server_ini_file}/.anon",
      changes => $changes,
      notify  => Service['hhvm'],
      require => Package['hhvm'],
    }
  }

  $hhvm_php_ini_file = '/etc/hhvm/php.ini'

  # config file could contain no php_ini key
  $hhvm_php_inis = array_true($hhvm_values, 'php_ini') ? {
    true    => $hhvm_values['php_ini'],
    default => { }
  }

  each( $hhvm_php_inis ) |$key, $value| {
    $changes = [ "set '${key}' '${value}'" ]

    augeas { "${key}: ${value}":
      lens    => 'PHP.lns',
      incl    => $hhvm_php_ini_file,
      context => "/files${hhvm_php_ini_file}/.anon",
      changes => $changes,
      notify  => Service['hhvm'],
      require => Package['hhvm'],
    }
  }

  if hash_key_equals($hhvm_values, 'composer', 1)
    and ! defined(Class['puphpet::php::composer'])
  {
    class { 'puphpet::php::composer':
      php_package   => 'hhvm',
      composer_home => $hhvm_values['composer_home'],
    }
  }
}
