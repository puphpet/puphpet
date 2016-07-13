class puphpet::python::pre {

  include ::pyenv::params

  each( $::pyenv::params::python_build_packages ) |$key, $package| {
    if ! defined(Package[$package]) {
      package { $package:
        ensure => present,
      }
    }
  }

}
