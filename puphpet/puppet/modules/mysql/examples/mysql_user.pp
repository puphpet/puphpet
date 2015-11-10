$mysql_root_pw = 'password'

class { 'mysql::server':
  root_password => 'password',
}

mysql_user{ 'redmine@localhost':
  ensure        => present,
  password_hash => mysql_password('redmine'),
  require       => Class['mysql::server'],
}

mysql_user{ 'dan@localhost':
  ensure        => present,
  password_hash => mysql_password('blah')
}

mysql_user{ 'dan@%':
  ensure        => present,
  password_hash => mysql_password('blah'),
}

mysql_user{ 'socketplugin@%':
  ensure => present,
  plugin => 'unix_socket',
}

mysql_user{ 'socketplugin@%':
  ensure        => present,
  password_hash => mysql_password('blah'),
  plugin        => 'mysql_native_password',
}
