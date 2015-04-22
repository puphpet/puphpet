if $mariadb_values == undef { $mariadb_values = hiera_hash('mariadb', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }

include puphpet::params
include puphpet::apache::params
include puphpet::mysql::params

if array_true($mariadb_values, 'install') and !array_true($mysql_values, 'install') {
  include mysql::params

  if array_true($apache_values, 'install')
    or array_true($nginx_values, 'install')
  {
    $mysql_webserver_restart = true
  } else {
    $mysql_webserver_restart = false
  }

  # fetch repo for specific version
  class { 'puphpet::mariadb':
    version => $mariadb_values['settings']['version']
  }

  if array_true($php_values, 'install') {
    $mariadb_php_installed = true
    $mariadb_php_package   = 'php'
  } elsif array_true($hhvm_values, 'install') {
    $mariadb_php_installed = true
    $mariadb_php_package   = 'hhvm'
  } else {
    $mariadb_php_installed = false
  }

  if empty($mariadb_values['settings']['root_password']) {
    fail( 'MariaDB requires choosing a root password. Please check your config.yaml file.' )
  }

  $mariadb_override_options = deep_merge($mysql::params::default_options, {
    'mysqld' => {
      'tmpdir' => "${mysql::params::datadir}/tmp",
    }
  })

  $mariadb_settings = delete(deep_merge({
      'package_name'     => $puphpet::params::mariadb_package_server_name,
      'service_name'     => 'mysql',
      'restart'          => true,
      'override_options' => $mariadb_override_options,
      require            => Class['puphpet::mariadb'],
    }, $mariadb_values['settings']), 'version')

  create_resources('class', {
    'mysql::server' => $mariadb_settings
  })

  class { 'mysql::client':
    package_name => $puphpet::params::mariadb_package_client_name
  }

  # prevent problems with being unable to create dir in /tmp
  if ! defined(File[$mariadb_override_options['mysqld']['tmpdir']]) {
    file { $mariadb_override_options['mysqld']['tmpdir']:
      ensure  => directory,
      owner   => $mariadb_user,
      group   => $mysql::params::root_group,
      mode    => '0775',
      require => Class['mysql::client'],
      notify  => Service[$mariadb_settings['service_name']]
    }
  }

  $mariadb_user = $mariadb_override_options['mysqld']['user']

  if ! defined(User[$mariadb_user]) {
    user { $mariadb_user:
      ensure => present,
    }
  }

  if ! defined(Group[$mysql::params::root_group]) {
    group { $mysql::params::root_group:
      ensure => present,
    }
  }

  if ! defined(File[$mysql::params::datadir]) {
    file { $mysql::params::datadir:
      ensure => directory,
      group  => $mysql::params::root_group,
      before => Class['mysql::server']
    }
  }

  $mariadb_pidfile_dir = $mariadb_override_options['mysqld']['pid-file']

  exec { 'Create pidfile parent directory':
    command => "mkdir -p $(dirname ${mariadb_pidfile_dir})",
    unless  => "test -d $(dirname ${mariadb_pidfile_dir})",
    before  => Class['mysql::server'],
    require => [
      User[$mariadb_user],
      Group[$mysql::params::root_group]
    ],
  }
  -> exec { 'Set pidfile parent directory permissions':
    command => "chown \
      ${mariadb_user}:${mysql::params::root_group} \
      $(dirname ${mariadb_pidfile_dir})",
  }

  Mysql_user <| |>
  -> Mysql_database <| |>
  -> Mysql_grant <| |>

  # config file could contain no users key
  $mariadb_users = array_true($mariadb_values, 'users') ? {
    true    => $mariadb_values['users'],
    default => { }
  }

  each( $mariadb_users ) |$key, $user| {
    # root user doesn't need to be defined
    if $user['name'] !~ /^root/  {
      # if no host passed with username, default to localhost
      if '@' in $user['name'] {
        $name = $user['name']
      } else {
        $name = "${user['name']}@localhost"
      }

      # force to_string to convert possible ints
      $password_hash = mysql_password(to_string($user['password']))

      if defined( Mysql_user[$name] ) {
        Mysql_user <| title == $name |> {
          password_hash => $password_hash,
        }
      } else {
        $user_merged = delete(merge($user, {
          ensure          => 'present',
          'password_hash' => $password_hash,
        }), ['name', 'password'])

        create_resources( mysql_user, { "${name}" => $user_merged })
      }
    }
  }

  # config file could contain no databases key
  $mariadb_databases = array_true($mariadb_values, 'databases') ? {
    true    => $mariadb_values['databases'],
    default => { }
  }

  each( $mariadb_databases ) |$key, $database| {
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
  $mariadb_grants = array_true($mariadb_values, 'grants') ? {
    true    => $mariadb_values['grants'],
    default => { }
  }

  each( $mariadb_grants ) |$key, $grant| {
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

  if ! defined(Package['mysql-libs']) {
    package { 'mysql-libs':
      ensure => purged,
      before => Class['mysql::server'],
    }
  }

  if $mariadb_php_installed and $mariadb_php_package == 'php' {
    if $::osfamily == 'redhat' and $php_values['settings']['version'] == '53' {
      $mariadb_php_module = 'mysql'
    } elsif $::lsbdistcodename == 'lucid' or $::lsbdistcodename == 'squeeze' {
      $mariadb_php_module = 'mysql'
    } else {
      $mariadb_php_module = 'mysqlnd'
    }

    if ! defined(Puphpet::Php::Module[$mariadb_php_module]) {
      puphpet::php::module { $mariadb_php_module:
        service_autorestart => $mariadb_webserver_restart,
      }
    }
  }

  if array_true($mariadb_values, 'adminer')
    and $mariadb_php_installed
    and ! defined(Class['puphpet::adminer'])
  {
    $mariadb_apache_webroot = $puphpet::params::apache_webroot_location
    $mariadb_nginx_webroot = $puphpet::params::nginx_webroot_location

    if array_true($apache_values, 'install') {
      $mariadb_adminer_webroot_location = $mariadb_apache_webroot
    } elsif array_true($nginx_values, 'install') {
      $mariadb_adminer_webroot_location = $mariadb_nginx_webroot
    } else {
      $mariadb_adminer_webroot_location = $mariadb_apache_webroot
    }

    class { 'puphpet::adminer':
      location    => "${mariadb_adminer_webroot_location}/adminer",
      owner       => 'www-data',
      php_package => $mariadb_php_package
    }
  }
}
