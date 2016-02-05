class puphpet_mongodb (
  $mongodb,
  $apache,
  $nginx,
  $php
) {

  if array_true($apache, 'install') or array_true($nginx, 'install') {
    $webserver_restart = true
  } else {
    $webserver_restart = false
  }

  file { ['/data', '/data/db']:
    ensure => directory,
    mode   => '0775',
    before => Class['mongodb::globals'],
  }

  Class['mongodb::globals']
  -> Class['mongodb::server']
  -> Class['mongodb::client']

  # The GUI does not choose a version by default
  $global_settings = array_true($mongodb, 'global') ? {
    true    => $mongodb['global'],
    default => { }
  }

  $merged_globals = merge({
    'manage_package_repo' => true,
    'version'             => $::osfamily ? {
      'debian' => '2.6.11',
      'redhat' => '2.6.11-1',
    },
  }, $global_settings)

  create_resources('class', {
    'mongodb::globals' => $merged_globals
  })

  create_resources('class', {
    'mongodb::server' => $mongodb['settings']
  })

  class { 'mongodb::client': }

  if ! defined(Package['mongodb-org-tools']) {
    package {'mongodb-org-tools':
      require => Class['mongodb::client']
    }
  }

  # MongoDB module does not handle creating log and pidfile directories
  if ! defined(User[$::mongodb::params::user]) {
    user { $::mongodb::params::user:
      ensure     => present,
      managehome => false,
    }
  }

  file { '/var/log/mongodb':
    ensure  => directory,
    owner   => $::mongodb::params::user,
    mode    => '0775',
    notify  => Service[$::mongodb::globals::service_name],
    require => User[$::mongodb::params::user]
  }
  -> file { '/var/run/mongodb':
    ensure  => directory,
    owner   => $::mongodb::params::user,
    mode    => '0775',
    notify  => Service[$::mongodb::globals::service_name],
  }
  -> file { $::mongodb::params::pidfilepath:
    ensure  => file,
    owner   => $::mongodb::params::user,
    mode    => '0775',
    notify  => Service[$::mongodb::globals::service_name],
  }
  -> file { $::mongodb::params::logpath:
    ensure  => file,
    owner   => $::mongodb::params::user,
    mode    => '0775',
    notify  => Service[$::mongodb::globals::service_name],
  }

  each( $mongodb['databases'] ) |$key, $database| {
    $merged = delete(merge($database, {
      'dbname' => $database['name'],
      require  => Package['mongodb-org-tools'],
    }), 'name')

    create_resources( puphpet::mongodb::db, {
      "${database['user']}@${database['name']}" => $merged
    })
  }

  if array_true($php, 'install') and ! defined(Puphpet::Php::Pecl['mongo']) {
    puphpet::php::pecl { 'mongo':
      service_autorestart => $webserver_restart,
      require             => Class['mongodb::server']
    }
  }

}
