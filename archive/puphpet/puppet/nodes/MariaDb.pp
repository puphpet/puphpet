if $mariadb_values == undef { $mariadb_values = hiera_hash('mariadb', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }

include puphpet::params

if hash_key_equals($mariadb_values, 'install', 1) {
  include mysql::params

  if empty($mariadb_values['settings']['root_password']) {
    fail( 'MariaDB requires choosing a root password. Please check your config.yaml file.' )
  }

  if hash_key_equals($apache_values, 'install', 1)
    or hash_key_equals($nginx_values, 'install', 1)
  {
    $mariadb_webserver_restart = true
  } else {
    $mariadb_webserver_restart = false
  }

  if hash_key_equals($php_values, 'install', 1) {
    $mariadb_php_installed = true
    $mariadb_php_package   = 'php'
  } elsif hash_key_equals($hhvm_values, 'install', 1) {
    $mariadb_php_installed = true
    $mariadb_php_package   = 'hhvm'
  } else {
    $mariadb_php_installed = false
  }

  # fetch repo for specific version
  class { 'puphpet::mariadb':
    version => $mariadb_values['settings']['version']
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

  create_resources('class', {
    'mysql::server' => $mariadb_settings
  })

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

  if ! defined(File[$mysql::params::socket]) {
    file { $mysql::params::socket :
      ensure  => file,
      group   => $mysql::params::root_group,
      before  => Class['mysql::server'],
      require => File[$mysql::params::datadir]
    }
  }

  if ! defined(Package['mysql-libs']) {
    package { 'mysql-libs':
      ensure => purged,
      before => Class['mysql::server'],
    }
  }

  class { 'mysql::client':
    package_name => $puphpet::params::mariadb_package_client_name
  }

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

  each( $mariadb_values['databases'] ) |$key, $database| {
    $database_merged = delete(merge($database, {
      'dbname' => $database['name'],
    }), 'name')

    create_resources( puphpet::mysql::db, {
      "${database['user']}@${database['name']}" => $database_merged
    })
  }

  if $mariadb_php_installed and $mariadb_php_package == 'php' {
    if $::osfamily == 'redhat' and $php_values['version'] == '53' {
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

  if hash_key_equals($mariadb_values, 'adminer', 1)
    and $mariadb_php_installed
    and ! defined(Class['puphpet::adminer'])
  {
    $mariadb_apache_webroot = $puphpet::params::apache_webroot_location
    $mariadb_nginx_webroot = $puphpet::params::nginx_webroot_location

    if hash_key_equals($apache_values, 'install', 1) {
      $mariadb_adminer_webroot_location = $mariadb_apache_webroot
    } elsif hash_key_equals($nginx_values, 'install', 1) {
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
