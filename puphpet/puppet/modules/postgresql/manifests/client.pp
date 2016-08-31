# Install client cli tool. See README.md for more details.
class postgresql::client (
  $file_ensure    = 'file',
  $package_name   = $postgresql::params::client_package_name,
  $package_ensure = 'present'
) inherits postgresql::params {
  validate_string($package_name)

  package { 'postgresql-client':
    ensure => $package_ensure,
    name   => $package_name,
    tag    => 'postgresql',
  }

  file { '/usr/local/bin/validate_postgresql_connection.sh':
    ensure => $file_ensure,
    source => 'puppet:///modules/postgresql/validate_postgresql_connection.sh',
    owner  => 0,
    group  => 0,
    mode   => '0755',
  }

}
