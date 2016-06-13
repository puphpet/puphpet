# This depends on daenney/pyenv: https://github.com/puphpet/puppet-pyenv
# Installs required packages from pyenv::params::python_build_packages
class puphpet::python::pre {

  include ::pyenv::params

  each( $pyenv::params::python_build_packages ) |$key, $package| {
    if ! defined(Package[$package]) {
      package { $package:
        ensure => present,
      }
    }
  }

}
