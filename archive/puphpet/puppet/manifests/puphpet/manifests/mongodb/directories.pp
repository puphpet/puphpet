class puphpet::mongodb::directories
{

  include ::mongodb::params
  include ::mongodb::globals

  # MongoDB module does not handle creating log and pidfile directories
  if ! defined(User[$::mongodb::params::user]) {
    user { $::mongodb::params::user:
      ensure     => present,
      managehome => false,
    }
  }

  file { '/var/log/mongodb':
    ensure  => directory,
    owner   => $::mongodb::params::user,
    mode    => '0775',
    notify  => Service[$::mongodb::globals::service_name],
    require => User[$::mongodb::params::user]
  }
  -> file { '/var/run/mongodb':
    ensure  => directory,
    owner   => $::mongodb::params::user,
    mode    => '0775',
    notify  => Service[$::mongodb::globals::service_name],
  }
  -> file { $::mongodb::params::pidfilepath:
    ensure  => file,
    owner   => $::mongodb::params::user,
    mode    => '0775',
    notify  => Service[$::mongodb::globals::service_name],
  }
  -> file { $::mongodb::params::logpath:
    ensure  => file,
    owner   => $::mongodb::params::user,
    mode    => '0775',
    notify  => Service[$::mongodb::globals::service_name],
  }

}
