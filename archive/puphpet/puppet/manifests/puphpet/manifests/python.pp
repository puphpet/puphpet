# Class for installing Pythons via pyenv
#
class puphpet::python {

  include ::puphpet::params

  $python = $puphpet::params::hiera['python']

  anchor{ 'puphpet::python::init': }
  -> class { 'puphpet::python::pre': }
  -> class { 'pyenv':
    manage_packages => false,
  }

  # config file could contain no versions key
  $versions = array_true($python, 'versions') ? {
    true    => $python['versions'],
    default => { }
  }

  each( $versions ) |$key, $version| {
    puphpet::python::install { "python-{$version['version']}":
      version    => $version['version'],
      virtualenv => $version['virtualenv'],
      require    => Class['pyenv'],
      before     => Anchor['puphpet::python::end']
    }
  }

  anchor{ 'puphpet::python::end': }

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
        require  => Anchor['puphpet::python::end'],
      }
    }
  }

}
