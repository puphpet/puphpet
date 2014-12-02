if $php_values == undef { $php_values = hiera_hash('php', false) }
if $xhprof_values == undef { $xhprof_values = hiera_hash('xhprof', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }

include puphpet::params

if hash_key_equals($xhprof_values, 'install', 1)
  and hash_key_equals($php_values, 'install', 1)
{
  if $::operatingsystem == 'ubuntu'
    and $::lsbdistcodename in ['lucid', 'maverick', 'natty', 'oneiric', 'precise']
  {
    apt::key { '8D0DC64F': key_server => 'hkp://keyserver.ubuntu.com:80' }
    apt::ppa { 'ppa:brianmercer/php5-xhprof': require => Apt::Key['8D0DC64F'] }
  }

  $xhprof_php_prefix = $::osfamily ? {
    'debian' => 'php5-',
    'redhat' => 'php-',
  }

  if hash_key_equals($apache_values, 'install', 1)
    and hash_key_equals($php_values, 'mod_php', 1)
  {
    $xhprof_webserver_service = 'httpd'
  } elsif hash_key_equals($apache_values, 'install', 1)
    or hash_key_equals($nginx_values, 'install', 1)
  {
    $xhprof_webserver_service = "${xhprof_php_prefix}fpm"
  } else {
    $xhprof_webserver_service = undef
  }

  if hash_key_equals($apache_values, 'install', 1) {
    $xhprof_webroot_location = '/var/www/default'
  } elsif hash_key_equals($nginx_values, 'install', 1) {
    $xhprof_webroot_location = $puphpet::params::nginx_webroot_location
  } else {
    $xhprof_webroot_location = $xhprof_values['location']
  }

  if ! defined(Package['graphviz']) {
    package { 'graphviz':
      ensure => present,
    }
  }

  class { 'puphpet::php::xhprof':
    php_version       => $php_values['version'],
    webroot_location  => $xhprof_webroot_location,
    webserver_service => $xhprof_webserver_service
  }
}
