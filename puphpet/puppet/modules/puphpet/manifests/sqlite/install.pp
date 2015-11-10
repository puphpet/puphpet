# This class manages the installation of the sqlite
# database.
class puphpet::sqlite::install {
  if ! defined(Package['sqlite']) {
    package { 'sqlite':
      ensure => installed,
    }
  }

  if ! defined(Group['sqlite']) {
    group { 'sqlite':
      ensure => present
    }
  }

  if ! defined(User['sqlite']) {
    user { 'sqlite':
      ensure     => present,
      managehome => false,
      groups     => 'sqlite',
      require    => Group['sqlite'],
    }
  }

  if ! defined(File['/var/lib/sqlite']) {
    file { '/var/lib/sqlite':
      ensure  => directory,
      owner   => 'sqlite',
      group   => 'sqlite',
      mode    => '0775',
      require => User['sqlite']
    }
  }
}
