if $python_values == undef { $python_values = hiera_hash('python', false) }

include puphpet::params

if hash_key_equals($python_values, 'install', 1) {
  include pyenv::params

  puphpet::python::preinstall { 'foo':
    before => Class['pyenv'],
  }

  class { 'pyenv':
    manage_packages => false,
  }

  if count($python_values['versions']) > 0 {
    create_resources(puphpet::python::install, $python_values['versions'])
  }

  each( $python_values['packages'] ) |$key, $package| {
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
