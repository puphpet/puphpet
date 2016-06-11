# This depends on puppetlabs/apt: https://github.com/puppetlabs/puppetlabs-apt
# Adds Apache > 2.4.10 repo for Ubuntu
class puphpet::apache::repo::ubuntu {

  if ! defined(Apt::Key['14AA40EC0831756756D7F66C4F4EA0AAE5267A6C']){
    ::apt::key { '14AA40EC0831756756D7F66C4F4EA0AAE5267A6C':
      server => 'hkp://keyserver.ubuntu.com:80'
    }
  }

  # This repo contains Apache 2.4.10+ for Precise
  if $::lsbdistcodename == 'precise' and ! defined(Apt::Ppa['ppa:ondrej/php5']) {
    ::apt::ppa { 'ppa:ondrej/php5':
      require => Apt::Key['14AA40EC0831756756D7F66C4F4EA0AAE5267A6C']
    }
  } elsif ! defined(Apt::Ppa['ppa:ondrej/apache2']){
    ::apt::ppa { 'ppa:ondrej/apache2':
      require => Apt::Key['14AA40EC0831756756D7F66C4F4EA0AAE5267A6C']
    }
  }

}
