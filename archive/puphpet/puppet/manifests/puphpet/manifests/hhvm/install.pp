# Class for configuring HHVM
#
#  [*override_php_alias*]
#    Point /usr/bin/php to HHVM for drop-in replacement
#
class puphpet::hhvm::install (
  $override_php_alias = true
) inherits puphpet::hhvm::params {

  group { $puphpet::hhvm::params::group:
    ensure => present,
  }

  user { $puphpet::hhvm::params::user:
    ensure     => present,
    groups     => [$puphpet::hhvm::params::group],
    managehome => false,
    require    => Group[$puphpet::hhvm::params::group],
  }

  case $::lsbdistcodename {
    'wheezy': {
      class { 'puphpet::hhvm::repo::debian7': }
    }
    'precise': {
      class { 'puphpet::hhvm::repo::ubuntu1204': }
    }
    'trusty': {
      class { 'puphpet::hhvm::repo::ubuntu1404': }

      package { 'libdouble-conversion1':
        ensure => present,
        before => Package[$puphpet::hhvm::params::package_name],
      }

      package { 'liblz4-1':
        ensure => present,
        before => Package[$puphpet::hhvm::params::package_name],
      }
    }
    default: {
      fail('HHVM not supported on this distro')
    }
  }

  package { $puphpet::hhvm::params::package_name:
    ensure => present
  }

  service { $puphpet::hhvm::params::service_name:
    ensure  => 'running',
    require => [
      User[$puphpet::hhvm::params::user],
      Package[$puphpet::hhvm::params::package_name],
    ],
  }

  if $override_php_alias == true {
    file { '/usr/bin/php':
      ensure  => 'link',
      target  => '/usr/bin/hhvm',
      require => Package[$puphpet::hhvm::params::package_name]
    }
  }

}
