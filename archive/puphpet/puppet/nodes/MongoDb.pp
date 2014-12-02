if $mongodb_values == undef { $mongodb_values = hiera_hash('mongodb', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }

include puphpet::params

if hash_key_equals($apache_values, 'install', 1)
  or hash_key_equals($nginx_values, 'install', 1)
{
  $mongodb_webserver_restart = true
} else {
  $mongodb_webserver_restart = false
}

if hash_key_equals($mongodb_values, 'install', 1) {
  file { ['/data', '/data/db']:
    ensure  => directory,
    mode    => 0775,
    before  => Class['mongodb::globals'],
  }

  Class['mongodb::globals']
  -> Class['mongodb::server']

  class { 'mongodb::globals':
    manage_package_repo => true,
  }

  create_resources('class', { 'mongodb::server' => $mongodb_values['settings'] })

  if $::osfamily == 'redhat' {
    class { 'mongodb::client':
      require => Class['mongodb::server']
    }
  }

  if count($mongodb_values['databases']) > 0 {
    each( $mongodb_values['databases'] ) |$key, $database| {
      $database_merged = delete(merge($database, {
        'dbname' => $database['name'],
      }), 'name')

      create_resources( mongodb_db, {
        "${database['user']}@${database['name']}" => $database_merged
      })
    }
  }

  if hash_key_equals($php_values, 'install', 1)
    and ! defined(Puphpet::Php::Pecl['mongo'])
  {
    puphpet::php::pecl { 'mongo':
      service_autorestart => $mongodb_webserver_restart,
      require             => Class['mongodb::server']
    }
  }
}

define mongodb_db (
  $dbname,
  $user,
  $password,
  $roles     = ['dbAdmin', 'readWrite', 'userAdmin'],
  $tries     = 10,
) {
  if ! value_true($name) or ! value_true($password) {
    fail( 'MongoDB requires that name and password be set. Please check your settings!' )
  }

  if ! defined(Mongodb_database[$dbname]) {
    mongodb_database { $dbname:
      ensure  => present,
      tries   => $tries,
      require => Class['mongodb::server'],
    }
  }

  $hash = mongodb_password($user, $password)

  if ! defined(Mongodb_user[$user]) {
    mongodb_user { $user:
      ensure        => present,
      password_hash => $hash,
      database      => $dbname,
      roles         => $roles,
      require       => Mongodb_database[$dbname],
    }
  }
}
