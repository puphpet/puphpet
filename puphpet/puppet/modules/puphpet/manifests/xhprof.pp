class puphpet::xhprof (
  $php_version      = '54',
  $webroot_location = '/var/www',
  $webserver_service
) inherits puphpet::params {

  warning('puphpet::xhprof is deprecated; please use puphpet::php::xhprof')

  class { '::puphpet::php::xhprof':
    php_version       => $php_version,
    webroot_location  => $webroot_location,
    webserver_service => webserver_service,
  }

}
