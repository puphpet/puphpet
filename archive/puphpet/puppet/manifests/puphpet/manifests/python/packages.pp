define puphpet::python::packages (
  $packages = $puphpet::python::params::packages,
) {

  include ::puphpet::python::params

  each( $packages ) |$key, $package| {
    $package_array = split($package, '@')
    $package_name = $package_array[0]

    if count($package_array) == 2 {
      $package_ensure = $package_array[1]
    } else {
      $package_ensure = present
    }

    if ! defined(Package[$package_name]) {
      package { $package_name:
        ensure   => $package_ensure,
        provider => pip,
        require  => Anchor['puphpet::python::end'],
      }
    }
  }

}
