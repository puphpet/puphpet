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

    if count($postgresql_values['databases']) > 0 {
      each( $postgresql_values['databases'] ) |$key, $database| {
        $database_merged = delete(merge($database, {
          'dbname' => $database['name'],
        }), 'name')

        create_resources( postgresql_db, {
          "${database['user']}@${database['name']}" => $database_merged
        })
      }
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

  if hash_key_equals($postgresql_values, 'adminer', 1) and $postgresql_php_installed {
    if hash_key_equals($apache_values, 'install', 1) {
      $postgresql_adminer_webroot_location = '/var/www/default'
    } elsif hash_key_equals($nginx_values, 'install', 1) {
      $postgresql_adminer_webroot_location = $puphpet::params::nginx_webroot_location
    } else {
      $postgresql_adminer_webroot_location = '/var/www/default'
    }

    class { 'puphpet::adminer':
      location    => "${postgresql_adminer_webroot_location}/adminer",
      owner       => 'www-data',
      php_package => $postgresql_php_package
    }
  }
}

define postgresql_db (
  $dbname,
  $user,
  $password,
  $encoding   = $postgresql::server::encoding,
  $locale     = $postgresql::server::locale,
  $grant      = 'ALL',
  $tablespace = undef,
  $template   = 'template0',
  $istemplate = false,
  $owner      = undef,
  $sql_file   = false
) {
  if ! value_true($dbname) or ! value_true($user)
    or ! value_true($password)
  {
    fail( 'PostgreSQL DB requires that name, user, password and grant be set. Please check your settings!' )
  }

  if ! defined(Postgresql::Server::Database[$dbname]) {
    postgresql::server::database { $dbname:
      encoding   => $encoding,
      tablespace => $tablespace,
      template   => $template,
      locale     => $locale,
      istemplate => $istemplate,
      owner      => $owner,
    }
  }

  if ! defined(Postgresql::Server::Role[$user]) {
    postgresql::server::role { $user:
      password_hash => postgresql_password($user, $password),
    }
  }

  $grant_string = "GRANT ${user} - ${grant} - ${dbname}"

  if ! defined(Postgresql::Server::Database_grant[$grant_string]) {
    postgresql::server::database_grant { $grant_string:
      privilege => $grant,
      db        => $dbname,
      role      => $user,
    }
  }

  if($tablespace != undef and defined(Postgresql::Server::Tablespace[$tablespace])) {
    Postgresql::Server::Tablespace[$tablespace] -> Postgresql::Server::Database[$dbname]
  }

  if $sql_file {
    $table = "${dbname}.*"

    exec{ "${dbname}-import":
      command     => "sudo -u postgres psql ${dbname} < ${sql_file}",
      logoutput   => true,
      refreshonly => true,
      require     => Postgresql::Server::Database_grant[$grant_string],
      onlyif      => "test -f ${sql_file}",
      subscribe   => Postgresql::Server::Database[$dbname],
    }
  }
}
