class puphpet_python (
  $python
) {

  include pyenv::params
  require supervisord::pip

  puphpet::python::preinstall { 'foo':
    before => Class['pyenv'],
  }

  class { 'pyenv':
    manage_packages => false,
  }

  if count($python['versions']) > 0 {
    create_resources(puphpet::python::install, $python['versions'])
  }

  each( $python['packages'] ) |$key, $package| {
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
      }
    }
  }

}
