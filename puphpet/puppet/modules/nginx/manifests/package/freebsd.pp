# Class: nginx::package::freebsd
#
# Manage the nginx package on FreeBSD
class nginx::package::freebsd (
    $package_name   = 'nginx',
    $package_ensure = 'present'
) {

  package { $package_name:
    ensure  => $package_ensure,
  }
}
