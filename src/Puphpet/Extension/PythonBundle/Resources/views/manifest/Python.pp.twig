if $python_values == undef { $python_values = hiera_hash('python', false) }

include puphpet::params

if hash_key_equals($python_values, 'install', 1) {
  include pyenv::params

  install_python_packages { 'foo':
    before => Class['pyenv'],
  }

  class { 'pyenv':
    manage_packages => false,
  }

  if count($python_values['versions']) > 0 {
    create_resources(install_python, $python_values['versions'])
  }

  if count($python_values['packages']) > 0 {
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
}

define install_python (
  $version,
  $virtualenv = false,
) {

  $install_virtualenv = value_true($virtualenv) ? {
    true    => true,
    default => false,
  }

  if value_true($version) {
    pyenv_python { $version:
      keep       => true,
      virtualenv => $install_virtualenv,
      ensure     => present,
      require    => Class['pyenv'],
    } ->
    file { "python v${version} symlink":
      ensure => link,
      path   => "/usr/bin/python${version}",
      target => "/usr/local/pyenv/versions/${version}/bin/python",
    } ->
    file { "python v${version} virtualenv symlink":
      ensure => link,
      path   => "/usr/bin/virtualenv-${version}",
      target => "/usr/local/pyenv/versions/${version}/bin/virtualenv",
    }
  }

}

define install_python_packages {
  each( $pyenv::params::python_build_packages ) |$key, $package| {
    if ! defined(Package[$package]) {
      package { $package:
        ensure => present,
      }
    }
  }
}
