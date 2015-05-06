if $mysql_values == undef { $mysql_values = hiera_hash('mysql', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }

include puphpet::params
include puphpet::apache::params
include puphpet::mysql::params

if array_true($mysql_values, 'install') {
  include mysql::params

  if array_true($apache_values, 'install')
    or array_true($nginx_values, 'install')
  {
    $mysql_webserver_restart = true
  } else {
    $mysql_webserver_restart = false
  }

  $mysql_version = to_string($mysql_values['settings']['version'])

  class { 'puphpet::mysql::repo':
    version => $mysql_version,
  }

  if $mysql_version in ['55', '5.5'] {
    $mysql_server_package = $puphpet::mysql::params::mysql_server_55
    $mysql_client_package = $puphpet::mysql::params::mysql_client_55
  } elsif $mysql_version in ['56', '5.6'] {
    $mysql_server_package = $puphpet::mysql::params::mysql_server_56
    $mysql_client_package = $puphpet::mysql::params::mysql_client_56
  }

  if array_true($php_values, 'install') {
    $mysql_php_installed = true
    $mysql_php_package   = 'php'
  } elsif array_true($hhvm_values, 'install') {
    $mysql_php_installed = true
    $mysql_php_package   = 'hhvm'
  } else {
    $mysql_php_installed = false
  }

  if empty($mysql_values['settings']['root_password']) {
    fail( 'MySQL requires choosing a root password. Please check your config.yaml file.' )
  }

  $mysql_override_options = deep_merge($mysql::params::default_options, {
    'mysqld' => {
      'tmpdir' => $mysql::params::tmpdir,
    }
  })

  $mysql_settings = delete(deep_merge({
    'package_name'     => $mysql_server_package,
    'restart'          => true,
    'override_options' => $mysql_override_options,
    require            => Class['puphpet::mysql::repo'],
  }, $mysql_values['settings']), 'version')

  create_resources('class', {
    'mysql::server' => $mysql_settings
  })

  class { 'mysql::client':
    package_name => $mysql_client_package,
    require      => Class['puphpet::mysql::repo'],
  }

  Mysql_user <| |>
  -> Mysql_database <| |>
  -> Mysql_grant <| |>

  # config file could contain no users key
  $mysql_users = array_true($mysql_values, 'users') ? {
    true    => $mysql_values['users'],
    default => { }
  }

  each( $mysql_users ) |$key, $user| {
    # if no host passed with username, default to localhost
    if '@' in $user['name'] {
      $name = $user['name']
    } else {
      $name = "${user['name']}@localhost"
    }

    # force to_string to convert possible ints
    $password_hash = mysql_password(to_string($user['password']))

    $user_merged = delete(merge($user, {
      ensure          => 'present',
      'password_hash' => $password_hash,
    }), ['name', 'password'])

    create_resources( mysql_user, { "${name}" => $user_merged })
  }

  # config file could contain no databases key
  $mysql_databases = array_true($mysql_values, 'databases') ? {
    true    => $mysql_values['databases'],
    default => { }
  }

  each( $mysql_databases ) |$key, $database| {
    $name = $database['name']
    $sql  = $database['sql']

    $import_timeout = array_true($database, 'import_timeout') ? {
      true    => $database['import_timeout'],
      default => 300
    }

    $database_merged = delete(merge($database, {
      ensure => 'present',
    }), ['name', 'sql', 'import_timeout'])

    create_resources( mysql_database, { "${name}" => $database_merged })

    if $sql {
      # Run import only on initial database creation
      $touch_file = "/.puphpet-stuff/db-import-${name}"

      exec{ "${name}-import":
        command     => "mysql ${name} < ${sql} && touch ${touch_file}",
        creates     => $touch_file,
        logoutput   => true,
        environment => "HOME=${::root_home}",
        path        => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
        timeout     => $import_timeout,
        require     => Mysql_database[$name]
      }
    }
  }

  # config file could contain no grants key
  $mysql_grants = array_true($mysql_values, 'grants') ? {
    true    => $mysql_values['grants'],
    default => { }
  }

  each( $mysql_grants ) |$key, $grant| {
    # if no host passed with username, default to localhost
    if '@' in $grant['user'] {
      $user = $grant['user']
    } else {
      $user = "${grant['user']}@localhost"
    }

    $table = $grant['table']

    $name = "${user}/${table}"

    $options = array_true($grant, 'options') ? {
      true    => $grant['options'],
      default => ['GRANT']
    }

    $grant_merged = merge($grant, {
      ensure    => 'present',
      'user'    => $user,
      'options' => $options,
    })

    create_resources( mysql_grant, { "${name}" => $grant_merged })
  }

  if $mysql_php_installed and $mysql_php_package == 'php' {
    if $::osfamily == 'redhat' and $php_values['settings']['version'] == '53' {
      $mysql_php_module = 'mysql'
    } elsif $::lsbdistcodename == 'lucid' or $::lsbdistcodename == 'squeeze' {
      $mysql_php_module = 'mysql'
    } else {
      $mysql_php_module = 'mysqlnd'
    }

    if ! defined(Puphpet::Php::Module[$mysql_php_module]) {
      puphpet::php::module { $mysql_php_module:
        service_autorestart => $mysql_webserver_restart,
      }
    }
  }

  if array_true($mysql_values, 'adminer')
    and $mysql_php_installed
    and ! defined(Class['puphpet::adminer'])
  {
    $mysql_apache_webroot = $puphpet::apache::params::default_vhost_dir
    $mysql_nginx_webroot  = $puphpet::params::nginx_webroot_location

    if array_true($apache_values, 'install') {
      $mysql_adminer_webroot_location = $mysql_apache_webroot
    } elsif array_true($nginx_values, 'install') {
      $mysql_adminer_webroot_location = $mysql_nginx_webroot
    } else {
      $mysql_adminer_webroot_location = $mysql_apache_webroot
    }

    class { 'puphpet::adminer':
      location    => "${mysql_adminer_webroot_location}/adminer",
      owner       => 'www-data',
      php_package => $mysql_php_package
    }
  }
}
