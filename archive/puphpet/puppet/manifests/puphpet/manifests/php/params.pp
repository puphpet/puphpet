class puphpet::php::params
  inherits ::puphpet::params
{

  $php_fpm_conf = $::osfamily ? {
    'Debian' => '/etc/php5/fpm/pool.d/www.conf',
    'Redhat' => '/etc/php-fpm.d/www.conf',
  }

  $php_cgi_package = $::osfamily ? {
    'Debian' => 'php5-cgi',
    'Redhat' => 'php-cgi'
  }

  $xhprof_package = $::osfamily ? {
    'Debian' => $::operatingsystem ? {
      'ubuntu' => false,
      'debian' => 'php5-xhprof'
    },
    'Redhat' => 'xhprof'
  }

}
