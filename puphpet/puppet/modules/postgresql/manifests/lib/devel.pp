# This class installs postgresql development libraries. See README.md for more
# details.
class postgresql::lib::devel(
  $package_name   = $postgresql::params::devel_package_name,
  $package_ensure = 'present',
  $link_pg_config = $postgresql::params::link_pg_config
) inherits postgresql::params {

  validate_string($package_name)

  package { 'postgresql-devel':
    ensure => $package_ensure,
    name   => $package_name,
    tag    => 'postgresql',
  }

  if $link_pg_config {
    if ( $postgresql::params::bindir != '/usr/bin' and $postgresql::params::bindir != '/usr/local/bin') {
      file { '/usr/bin/pg_config':
        ensure => link,
        target => "${postgresql::params::bindir}/pg_config",
      }
    }
  }

}
