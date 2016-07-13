# == Define Resource Type: puphpet::nodejs::npm_packages
#
# Installs NPM packages using npm provider.
#
# To install a specific version, use {package}@{version}.
# eg: "express@4.10.4". For latest just use {package}.
#
define puphpet::nodejs::npm_packages (
  $npm_packages = $::puphpet::nodejs::params::npm_packages
){

  include ::puphpet::nodejs::params

  each( $npm_packages ) |$package| {
      $npm_array = split($package, '@')

      if count($npm_array) == 2 {
        $npm_ensure = $npm_array[1]
      } else {
        $npm_ensure = present
      }

    if ! defined(Package[$npm_array[0]]) {
      package { $npm_array[0]:
        ensure   => $npm_ensure,
        provider => npm,
        require  => Package['nodejs']
      }
    }
  }

}
