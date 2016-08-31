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

  class { 'mongodb::globals':
    manage_package_repo => true,
  }

  create_resources('class', {
    'mongodb::server' => $mongodb['settings']
  })

  if $::osfamily == 'redhat' {
    class { 'mongodb::client':
      require => Class['mongodb::server']
    }
  }

  each( $mongodb['databases'] ) |$key, $database| {
    $merged = delete(merge($database, {
      'dbname' => $database['name'],
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
