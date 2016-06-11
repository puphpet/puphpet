class puphpet::mariadb::params
  inherits ::puphpet::params
{

  $mariadb_package_client_name = $::osfamily ? {
    'Debian' => 'mariadb-client',
    'Redhat' => 'MariaDB-client',
  }

  $mariadb_package_server_name = $::osfamily ? {
    'Debian' => 'mariadb-server',
    'Redhat' => 'MariaDB-server',
  }

}
