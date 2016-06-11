class puphpet::mysql::params {

  $mysql_server_55 = $::osfamily ? {
    'debian' => 'mysql-server-5.5',
    'redhat' => 'mysql-community-server',
  }

  $mysql_client_55 = $::osfamily ? {
    'debian' => 'mysql-client-5.5',
    'redhat' => 'mysql-community-client',
  }

  $mysql_server_56 = $::osfamily ? {
    'debian' => 'mysql-server',
    'redhat' => 'mysql-community-server',
  }

  $mysql_client_56 = $::osfamily ? {
    'debian' => 'mysql-client',
    'redhat' => 'mysql-community-client',
  }

}
