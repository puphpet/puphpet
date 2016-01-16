class puphpet_mariadb (
  $mariadb,
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

  $version = to_string($mariadb['settings']['version'])

  class { 'puphpet::mariadb':
    version => $version,
  }

  $server_package = $puphpet::params::mariadb_package_server_name
  $client_package = $puphpet::params::mariadb_package_client_name

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

  $settings = delete(deep_merge({
    'package_name'     => $server_package,
    'restart'          => true,
    'override_options' => $override_options,
    'service_name'     => 'mysql',
  }, $mariadb['settings']), ['version', 'root_password'])

  $settingsPw = deep_merge($settings, {
    'root_password' => $root_password
  })

  create_resources('class', {
    'mysql::server' => $settingsPw
  })

  class { 'mysql::client':
    package_name => $client_package,
  }

  $mariadb_user = $override_options['mysqld']['user']

  # Ensure the user exists
  if ! defined(User[$mariadb_user]) {
    user { $mariadb_user:
      ensure => present,
    }
  }

  # Ensure the group exists
  if ! defined(Group[$mysql::params::root_group]) {
    group { $mysql::params::root_group:
      ensure => present,
    }
  }

  # Ensure the data directory exists
  if ! defined(File[$mysql::params::datadir]) {
    file { $mysql::params::datadir:
      ensure => directory,
      group  => $mysql::params::root_group,
      before => Class['mysql::server']
    }
  }

  $mariadb_pidfile = $override_options['mysqld']['pid-file']

  # Ensure PID file directory exists
  exec { 'Create pidfile parent directory':
    command => "mkdir -p $(dirname ${mariadb_pidfile})",
    unless  => "test -d $(dirname ${mariadb_pidfile})",
    before  => Class['mysql::server'],
    require => [
      User[$mariadb_user],
      Group[$mysql::params::root_group]
    ],
  }
  -> exec { 'Set pidfile parent directory permissions':
    command => "chown \
      ${mariadb_user}:${mysql::params::root_group} \
      $(dirname ${mariadb_pidfile})",
  }

  Mysql_user <| |>
  -> Mysql_database <| |>
  -> Mysql_grant <| |>

  # config file could contain no users key
  $users = array_true($mariadb, 'users') ? {
    true    => $mariadb['users'],
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
  $databases = array_true($mariadb, 'databases') ? {
    true    => $mariadb['databases'],
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
  $grants = array_true($mariadb, 'grants') ? {
    true    => $mariadb['grants'],
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
    } else {
      $php_module = 'mysqlnd'
    }

    if ! defined(Puphpet::Php::Module[$php_module]) {
      puphpet::php::module { $php_module:
        service_autorestart => $webserver_restart,
      }
    }
  }

  if array_true($mariadb, 'adminer')
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
