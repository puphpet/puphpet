class mysql::server::account_security {
  mysql_user {
    [ 'root@127.0.0.1',
      'root@::1',
      '@localhost',
      '@%']:
    ensure  => 'absent',
    require => Anchor['mysql::server::end'],
  }
  if ($::fqdn != 'localhost.localdomain') {
    mysql_user {
      [ 'root@localhost.localdomain',
        '@localhost.localdomain']:
      ensure  => 'absent',
      require => Anchor['mysql::server::end'],
    }
  }
  if ($::fqdn != 'localhost') {
    mysql_user {
      [ "root@${::fqdn}",
        "@${::fqdn}"]:
      ensure  => 'absent',
      require => Anchor['mysql::server::end'],
    }
  }
  if ($::fqdn != $::hostname) {
    if ($::hostname != 'localhost') {
      mysql_user { ["root@${::hostname}", "@${::hostname}"]:
        ensure  => 'absent',
        require => Anchor['mysql::server::end'],
      }
    }
  }
  mysql_database { 'test':
    ensure  => 'absent',
    require => Anchor['mysql::server::end'],
  }
}
