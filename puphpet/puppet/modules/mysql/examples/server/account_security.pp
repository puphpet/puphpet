class { 'mysql::server':
  root_password => 'password',
}
class { 'mysql::server::account_security': }
