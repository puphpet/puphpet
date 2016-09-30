# == Class: puphpet::apache::ssl::snakeoil
#
# Sets up untrusted snakeoil SSL cert
# Installs required packages for generating cert
#
# Usage:
#
#  class { 'puphpet::apache::ssl::snakeoil': }
#
class puphpet::apache::ssl::snakeoil {

  include ::apache::params
  include ::puphpet::apache::params

  case $::osfamily {
    'debian': {
      $package = 'ssl-cert'

      $exec_cmd     = 'make-ssl-cert generate-default-snakeoil --force-overwrite'
      $exec_creates = [
        $puphpet::apache::params::ssl_cert_location,
        $puphpet::apache::params::ssl_key_location
      ]
      $exec_path    = [ '/bin/', '/usr/bin/', '/usr/sbin/' ]
    }
    'redhat': {
      $package = 'openssl'

      $exec_cmd     = "make-dummy-cert ${puphpet::apache::params::ssl_cert_location}"
      $exec_creates = $puphpet::apache::params::ssl_cert_location
      $exec_path    = [ '/bin/', '/usr/bin/', '/usr/sbin/', '/etc/pki/tls/certs/' ]
    }
  }

  if ! defined(Package[$package]) {
    package { $package:
      ensure => latest,
    }
  }

  exec { 'Generate snakeoil certificate':
    command => $exec_cmd,
    creates => $exec_creates,
    path    => $exec_path,
    require => [
      Package[$package],
      Class['apache'],
    ],
    notify  => Service[$::apache::params::service_name],
  }

}
