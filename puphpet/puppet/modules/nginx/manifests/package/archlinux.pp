# Class: nginx::package::archlinux
#
# This module manages NGINX package installation on Archlinux based systems
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class nginx::package::archlinux(
    $package_name   = 'nginx',
    $package_ensure = 'present'
  ) {

  package { $package_name:
    ensure  => $package_ensure,
  }

}
