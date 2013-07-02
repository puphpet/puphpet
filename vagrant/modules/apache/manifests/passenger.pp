# Class apache::passenger
#
# Apache resources specific for passenger
#
class apache::passenger {

  include apache

  case $::operatingsystem {
    ubuntu,debian,mint: {
      package { 'libapache2-mod-passenger':
        ensure => present;
      }

      exec { 'enable-passenger':
        command => '/usr/sbin/a2enmod passenger',
        creates => '/etc/apache2/mods-enabled/passenger.load',
        notify  => Service['apache'],
        require => [
          Package['apache'],
          Package['libapache2-mod-passenger']
        ],
      }
    }

    centos,redhat,scientific,fedora: {
      $osver = split($::operatingsystemrelease, '[.]')

      case $osver[0] {
        5: { require yum::repo::passenger }
        default: { }
      }
      package { 'mod_passenger':
        ensure => present;
      }
    }

    default: { }
  }

}
