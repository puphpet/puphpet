class { 'mysql::server':
  root_password => 'password'
}
mysql::db { 'mydb':
  user     => 'myuser',
  password => 'mypass',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE'],
}
mysql::db { "mydb_${fqdn}":
  user     => 'myuser',
  password => 'mypass',
  dbname   => 'mydb',
  host     => $::fqdn,
  grant    => ['SELECT', 'UPDATE'],
  tag      => $domain,
}
