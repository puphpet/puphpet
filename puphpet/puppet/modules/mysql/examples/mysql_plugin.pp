class { 'mysql::server':
  root_password => 'password'
}

$validate_password_soname = $::osfamily ? {
  windows => 'validate_password.dll',
  default => 'validate_password.so'
}

mysql::plugin { 'validate_password':
  ensure => present,
  soname => $validate_password_soname,
}

$auth_socket_soname = $::osfamily ? {
  windows => 'auth_socket.dll',
  default => 'auth_socket.so'
}

mysql::plugin { 'auth_socket':
  ensure => present,
  soname => $auth_socket_soname,
}
