class { 'mysql::server':
  root_password => 'password'
}
mysql::db{ ['test1', 'test2', 'test3']:
  ensure  => present,
  charset => 'utf8',
  require => Class['mysql::server'],
}
mysql::db{ 'test4':
  ensure  => present,
  charset => 'latin1',
}
mysql::db{ 'test5':
  ensure  => present,
  charset => 'binary',
  collate => 'binary',
}
