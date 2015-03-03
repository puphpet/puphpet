if $sqlite_values == undef { $sqlite_values = hiera_hash('sqlite', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }
if $mailcatcher_values == undef { $mailcatcher_values = hiera_hash('mailcatcher', false) }

include puphpet::params

if hash_key_equals($sqlite_values, 'install', 1) {
  if hash_key_equals($php_values, 'install', 1) {
    $sqlite_php_installed = true
    $sqlite_php_package   = 'php'
  } elsif hash_key_equals($hhvm_values, 'install', 1) {
    $sqlite_php_installed = true
    $sqlite_php_package   = 'hhvm'
  } else {
    $sqlite_php_installed = false
  }

  # puppet manifests for mailcatcher and sqlite are not compatible.
  if hash_key_equals($mailcatcher_values, 'install', 0) {
    class { 'sqlite': }
  }

  if is_hash($sqlite_values['databases'])
    and count($sqlite_values['databases']) > 0
  {
    create_resources(puphpet::sqlite::db, $sqlite_values['databases'])
  }

  if $sqlite_php_installed
    and $sqlite_php_package == 'php'
    and ! defined(Puphpet::Php::Pecl['sqlite'])
  {
    puphpet::php::pecl { 'sqlite':
      service_autorestart => true,
    }
  }

  if hash_key_equals($sqlite_values, 'adminer', 1) and $sqlite_php_installed {
    if hash_key_equals($apache_values, 'install', 1) {
      $sqlite_adminer_webroot = $puphpet::params::apache_webroot_location
    } elsif hash_key_equals($nginx_values, 'install', 1) {
      $sqlite_adminer_webroot = $puphpet::params::nginx_webroot_location
    } else {
      $sqlite_adminer_webroot = $puphpet::params::apache_webroot_location
    }

    class { 'puphpet::adminer':
      location    => "${sqlite_adminer_webroot}/adminer",
      owner       => 'www-data',
      php_package => $sqlite_php_package
    }
  }
}
