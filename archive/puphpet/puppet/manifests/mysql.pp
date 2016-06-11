class puphpet_mysql (
  $mysql,
  $apache,
  $nginx,
  $php,
  $hhvm
) {

  include puphpet::apache::params
  include puphpet::mysql::params
  include mysql::params

  if array_true($apache, 'install') or array_true($nginx, 'install') {
    $webserver_restart = true
  } else {
    $webserver_restart = false
  }

  $version = to_string($mysql['settings']['version'])

  class { 'puphpet::mysql::repo':
    version => $version,
  }

  if $version in ['55', '5.5'] {
    $server_package = $puphpet::mysql::params::mysql_server_55
    $client_package = $puphpet::mysql::params::mysql_client_55
  } elsif $version in ['56', '5.6'] {
    $server_package = $puphpet::mysql::params::mysql_server_56
    $client_package = $puphpet::mysql::params::mysql_client_56
  }

  if array_true($php, 'install') {
    $php_package = 'php'
  } elsif array_true($hhvm, 'install') {
    $php_package = 'hhvm'
  } else {
    $php_package = false
  }

  $root_password = array_true($mysql['settings'], 'root_password') ? {
    true    => $mysql['settings']['root_password'],
    default => $mysql::params::root_password
  }

  $override_options = deep_merge($mysql::params::default_options, {
    'mysqld' => {
      'tmpdir' => $mysql::params::tmpdir,
    }
  })

  $install_options = $::osfamily ? {
    'Debian' => '--force-yes',
    default  => undef,
  }

  $settings = delete(deep_merge({
    'package_name'     => $server_package,
    'restart'          => true,
    'override_options' => $override_options,
    'install_options'  => $install_options,
    require            => Class['puphpet::mysql::repo'],
  }, $mysql['settings']), ['version', 'root_password'])

  $settingsPw = deep_merge($settings, {
    'root_password' => $root_password
  })

  create_resources('class', {
    'mysql::server' => $settingsPw
  })

  class { 'mysql::client':
    package_name => $client_package,
    require      => Class['puphpet::mysql::repo'],
  }

  Mysql_user <| |>
  -> Mysql_database <| |>
  -> Mysql_grant <| |>

  # config file could contain no users key
  $users = array_true($mysql, 'users') ? {
    true    => $mysql['users'],
    default => { }
  }

  each( $users ) |$key, $user| {
    # if no host passed with username, default to localhost
    if '@' in $user['name'] {
      $name = $user['name']
    } else {
      $name = "${user['name']}@localhost"
    }

    # force to_string to convert possible ints
    $password_hash = mysql_password(to_string($user['password']))

    $merged = delete(merge($user, {
      ensure          => 'present',
      'password_hash' => $password_hash,
    }), ['name', 'password'])

    create_resources( mysql_user, { "${name}" => $merged })
  }

  # config file could contain no databases key
  $databases = array_true($mysql, 'databases') ? {
    true    => $mysql['databases'],
    default => { }
  }

  each( $databases ) |$key, $database| {
    $name = $database['name']
    $sql  = $database['sql']

    $import_timeout = array_true($database, 'import_timeout') ? {
      true    => $database['import_timeout'],
      default => 300
    }

    $merged = delete(merge($database, {
      ensure => 'present',
    }), ['name', 'sql', 'import_timeout'])

    create_resources( mysql_database, { "${name}" => $merged })

    if $sql != '' {
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
  $grants = array_true($mysql, 'grants') ? {
    true    => $mysql['grants'],
    default => { }
  }

  each( $grants ) |$key, $grant| {
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

    $merged = merge($grant, {
      ensure    => 'present',
      'user'    => $user,
      'options' => $options,
    })

    create_resources( mysql_grant, { "${name}" => $merged })
  }

  if $php_package == 'php' {
    if $::osfamily == 'redhat' and $php['settings']['version'] == '53' {
      $php_module = 'mysql'
    } elsif $::lsbdistcodename == 'lucid' or $::lsbdistcodename == 'squeeze' {
      $php_module = 'mysql'
    } elsif $::osfamily == 'debian' and $php['settings']['version'] in ['7.0', '70'] {
      $php_module = 'mysql'
    } elsif $::operatingsystem == 'ubuntu' and $php['settings']['version'] in ['5.6', '56'] {
      $php_module = 'mysql'
    } else {
      $php_module = 'mysqlnd'
    }

    if ! defined(Puphpet::Php::Module[$php_module]) {
      puphpet::php::module { $php_module:
        service_autorestart => $webserver_restart,
      }
    }
  }

  if array_true($mysql, 'adminer')
    and $php_package
    and ! defined(Class['puphpet::adminer'])
  {
    $apache_webroot = $puphpet::apache::params::default_vhost_dir
    $nginx_webroot  = $puphpet::params::nginx_webroot_location

    if array_true($apache, 'install') {
      $adminer_webroot = $apache_webroot
      Class['puphpet_apache']
      -> Class['puphpet::adminer']
    } elsif array_true($nginx, 'install') {
      $adminer_webroot = $nginx_webroot
      Class['puphpet_nginx']
      -> Class['puphpet::adminer']
    } else {
      fail( 'Adminer requires either Apache or Nginx to be installed.' )
    }

    class { 'puphpet::adminer':
      location => "${$adminer_webroot}/adminer",
      owner    => 'www-data'
    }
  }

}
