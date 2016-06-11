class puphpet::nginx::params
  inherits ::puphpet::params
{

  $nginx_default_conf_location = $::osfamily ? {
    'Debian' => '/etc/nginx/conf.d/default.conf',
    'Redhat' => '/etc/nginx/conf.d/default.conf'
  }

  $nginx_www_location = $::osfamily ? {
    'Debian' => '/var/www',
    'Redhat' => '/var/www'
  }

  $nginx_webroot_location = $::osfamily ? {
    'Debian' => '/var/www/html',
    'Redhat' => '/var/www/html'
  }

}
