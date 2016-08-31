# PRIVATE CLASS: do not call directly
class postgresql::server::install {
  $package_ensure      = $postgresql::server::package_ensure
  $package_name        = $postgresql::server::package_name
  $client_package_name = $postgresql::server::client_package_name

  $_package_ensure = $package_ensure ? {
    true     => 'present',
    false    => 'purged',
    'absent' => 'purged',
    default => $package_ensure,
  }

  package { 'postgresql-server':
    ensure => $_package_ensure,
    name   => $package_name,

    # This is searched for to create relationships with the package repos, be
    # careful about its removal
    tag    => 'postgresql',
  }

}
