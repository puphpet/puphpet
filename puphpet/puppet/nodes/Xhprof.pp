class puphpet_xhprof (
  $xhprof,
  $apache,
  $nginx,
  $php
) {

  include puphpet::apache::params

  # $::lsbdistcodename is blank in CentOS
  if $::operatingsystem == 'ubuntu'
    and $::lsbdistcodename in [
      'lucid', 'maverick', 'natty', 'oneiric', 'precise'
    ]
  {
    apt::key { '8D0DC64F':
      key_server => 'hkp://keyserver.ubuntu.com:80'
    }
    apt::ppa { 'ppa:brianmercer/php5-xhprof':
      require => Apt::Key['8D0DC64F']
    }
  }

  if array_true($apache, 'install') or array_true($nginx, 'install') {
    $service = $puphpet::php::settings::service
  } else {
    $service = undef
  }

  if array_true($apache, 'install') {
    $webroot = $puphpet::apache::params::default_vhost_dir
  } elsif array_true($nginx, 'install') {
    $webroot = $puphpet::params::nginx_webroot_location
  } else {
    $webroot = $xhprof['location']
  }

  if ! defined(Package['graphviz']) {
    package { 'graphviz':
      ensure => present,
    }
  }

  class { 'puphpet::php::xhprof':
    php_version       => $php['settings']['version'],
    webroot_location  => $webroot,
    webserver_service => $service
  }

}
