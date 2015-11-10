class { 'mysql::server':
  root_password => 'password'
}

class { 'mysql::server::backup':
  backupuser     => 'myuser',
  backuppassword => 'mypassword',
  backupdir      => '/tmp/backups',
}
