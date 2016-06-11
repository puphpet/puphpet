# This depends on
#   ajcrowe/supervisord: https://github.com/ajcrowe/puppet-supervisord

class puphpet::supervisord {

  include ::puphpet::python::pip

  if ! defined(Package['git']) {
    package { 'git':
      ensure  => present,
    }
  }

  if ! defined(Class['supervisord::pip']) {
    class { '::supervisord::pip':
      require => Package['git']
    }
  }

  if ! defined(Class['::supervisord']) {
    class { '::supervisord':
      install_pip => false,
      require     => [
        Class['puphpet::firewall::post'],
        Class['puphpet::python::pip'],
      ],
    }
  }

}
