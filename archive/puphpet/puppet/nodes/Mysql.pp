if $mysql_values == undef { $mysql_values = hiera_hash('mysql', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }

include puphpet::params

if hash_key_equals($mysql_values, 'install', 1) {
  include mysql::params

  if hash_key_equals($apache_values, 'install', 1)
    or hash_key_equals($nginx_values, 'install', 1)
  {
    $mysql_webserver_restart = true
  } else {
    $mysql_webserver_restart = false
  }

  if $::osfamily == 'redhat' {
    $rhel_mysql = 'http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm'

    $mysql_rhel_yum   = "yum -y --nogpgcheck install '${rhel_mysql}'"
    $mysql_rhel_touch = 'touch /.puphpet-stuff/mysql-community-release'

    exec { 'mysql-community-repo':
      command => "${mysql_rhel_yum} && ${mysql_rhel_touch}",
      creates => '/.puphpet-stuff/mysql-community-release'
    }

    $mysql_server_require             = Exec['mysql-community-repo']
    $mysql_server_server_package_name = 'mysql-community-server'
    $mysql_server_client_package_name = 'mysql-community-client'
  } else {
    $mysql_server_require             = []
    $mysql_server_server_package_name = $mysql::params::server_package_name
    $mysql_server_client_package_name = $mysql::params::client_package_name
  }

  if hash_key_equals($php_values, 'install', 1) {
    $mysql_php_installed = true
    $mysql_php_package   = 'php'
  } elsif hash_key_equals($hhvm_values, 'install', 1) {
    $mysql_php_installed = true
    $mysql_php_package   = 'hhvm'
  } else {
    $mysql_php_installed = false
  }

  if $mysql_values['root_password'] {
    $mysql_override_options = empty($mysql_values['override_options']) ? {
      true    => {},
      default => $mysql_values['override_options']
    }

    class { 'mysql::server':
      package_name     => $mysql_server_server_package_name,
      root_password    => $mysql_values['root_password'],
      require          => $mysql_server_require,
      override_options => $mysql_override_options
    }

    class { 'mysql::client':
      package_name => $mysql_server_client_package_name,
      require      => $mysql_server_require
    }

    each( $mysql_values['databases'] ) |$key, $database| {
      $database_merged = delete(merge($database, {
        'dbname' => $database['name'],
      }), 'name')

      create_resources( puphpet::mysql::db, {
        "${key}" => $database_merged
      })
    }

    if $mysql_php_installed and $mysql_php_package == 'php' {
      if $::osfamily == 'redhat' and $php_values['version'] == '53' {
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
  }

  if hash_key_equals($mysql_values, 'adminer', 1)
    and $mysql_php_installed
    and ! defined(Class['puphpet::adminer'])
  {
    $mysql_apache_webroot = $puphpet::params::apache_webroot_location
    $mysql_nginx_webroot = $puphpet::params::nginx_webroot_location

    if hash_key_equals($apache_values, 'install', 1) {
      $mysql_adminer_webroot_location = $mysql_apache_webroot
    } elsif hash_key_equals($nginx_values, 'install', 1) {
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
