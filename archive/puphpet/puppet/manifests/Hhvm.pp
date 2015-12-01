class puphpet_hhvm (
  $hhvm
) {

  class { 'puphpet::hhvm':
    nightly => $hhvm['nightly'],
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

  $server_ini = '/etc/hhvm/server.ini'

  # config file could contain no server_ini key
  $server_inis = array_true($hhvm, 'server_ini') ? {
    true    => $hhvm['server_ini'],
    default => { }
  }

  each( $server_inis ) |$key, $value| {
    $changes = [ "set '${key}' '${value}'" ]

    augeas { "${key}: ${value}":
      lens    => 'PHP.lns',
      incl    => $server_ini,
      context => "/files${server_ini}/.anon",
      changes => $changes,
      notify  => Service['hhvm'],
      require => Package['hhvm'],
    }
  }

  $php_ini = '/etc/hhvm/php.ini'

  # config file could contain no php_ini key
  $php_inis = array_true($hhvm, 'php_ini') ? {
    true    => $hhvm['php_ini'],
    default => { }
  }

  each( $php_inis ) |$key, $value| {
    $changes = [ "set '${key}' '${value}'" ]

    augeas { "${key}: ${value}":
      lens    => 'PHP.lns',
      incl    => $php_ini,
      context => "/files${php_ini}/.anon",
      changes => $changes,
      notify  => Service['hhvm'],
      require => Package['hhvm'],
    }
  }

  if array_true($hhvm, 'composer') and ! defined(Class['puphpet::php::composer']) {
    class { 'puphpet::php::composer':
      php_package   => 'hhvm',
      composer_home => $hhvm['composer_home'],
    }
  }

}
