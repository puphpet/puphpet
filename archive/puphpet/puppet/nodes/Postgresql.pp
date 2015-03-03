if $postgresql_values == undef { $postgresql_values = hiera_hash('postgresql', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }

include puphpet::params

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

  if $postgresql_values['settings']['root_password'] {
    group { $postgresql_values['settings']['user_group']:
      ensure => present
    }

    class { 'postgresql::globals':
      manage_package_repo => true,
      encoding            => $postgresql_values['settings']['encoding'],
      version             => $postgresql_values['settings']['version']
    }->
    class { 'postgresql::server':
      postgres_password => $postgresql_values['settings']['root_password'],
      version           => $postgresql_values['settings']['version'],
      require           => Group[$postgresql_values['settings']['user_group']]
    }

    each( $postgresql_values['databases'] ) |$key, $database| {
      $database_merged = delete(merge($database, {
        'dbname' => $database['name'],
      }), 'name')

      create_resources( puphpet::postgresql::db, {
        "${database['user']}@${database['name']}" => $database_merged
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
  }

  if hash_key_equals($postgresql_values, 'adminer', 1)
    and $postgresql_php_installed
  {
    $postgre_apache_webroot = $puphpet::params::apache_webroot_location
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
