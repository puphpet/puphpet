# Install the postgis postgresql packaging. See README.md for more details.
class postgresql::server::postgis (
  $package_name   = $postgresql::params::postgis_package_name,
  $package_ensure = 'present'
) inherits postgresql::params {
  validate_string($package_name)

  package { 'postgresql-postgis':
    ensure => $package_ensure,
    name   => $package_name,
    tag    => 'postgresql',
  }

  anchor { 'postgresql::server::postgis::start': }->
  Class['postgresql::server::install']->
  Package['postgresql-postgis']->
  Class['postgresql::server::service']->
  anchor { 'postgresql::server::postgis::end': }

  if $postgresql::globals::manage_package_repo {
    Class['postgresql::repo'] ->
    Package['postgresql-postgis']
  }
}
