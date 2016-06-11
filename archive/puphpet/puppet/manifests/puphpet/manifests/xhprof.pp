class puphpet::xhprof (
  $xhprof = $puphpet::params::config['xhprof'],
  $apache = $puphpet::params::config['apache'],
  $nginx  = $puphpet::params::config['nginx'],
  $php    = $puphpet::params::config['php'],
) {

  include puphpet::apache::params
  include puphpet::nginx::params
  include puphpet::php::settings

  # $::lsbdistcodename is blank in CentOS
  if $::operatingsystem == 'ubuntu'
    and $::lsbdistcodename in [
      'lucid', 'maverick', 'natty', 'oneiric', 'precise'
    ]
  {
    apt::key { '8D0DC64F':
      server => 'hkp://keyserver.ubuntu.com:80'
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
    $webroot = $puphpet::nginx::params::nginx_webroot_location
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
