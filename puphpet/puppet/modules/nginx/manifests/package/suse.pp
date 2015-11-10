# Class: nginx::package::suse
#
# This module manages NGINX package installation for SuSE based systems
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#  This module contains all of the required package for SuSE. Apache and all
#  other packages listed below are built into the packaged RPM spec for
#  SuSE and OpenSuSE.
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class nginx::package::suse (
  $package_name = 'nginx'
) {

  if $caller_module_name != $module_name {
    warning("${name} is deprecated as a public API of the ${module_name} module and should no longer be directly included in the manifest.")
  }

  package { $package_name:
    ensure => $nginx::package_ensure,
  }
}
