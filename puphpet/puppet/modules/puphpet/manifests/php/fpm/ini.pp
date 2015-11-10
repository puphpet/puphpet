# Defines where we can expect PHP-FPM ini files and paths to be located.
#
# debian 7.x
#    7.0
#        N/A
#    5.6
#        /etc/php5/fpm/php-fpm.conf
#    5.5
#        /etc/php5/fpm/php-fpm.conf
#    5.4
#        /etc/php5/fpm/php-fpm.conf
# ubuntu 14.04
#    7.0
#        /etc/php7/fpm/php-fpm.conf
#    5.6
#        /etc/php5/fpm/php-fpm.conf
#    5.5
#        /etc/php5/fpm/php-fpm.conf
#    5.4
#        N/A
# ubuntu 12.04
#    7.0
#        N/A
#    5.6
#        N/A
#    5.5
#        /etc/php5/fpm/php-fpm.conf
#    5.4
#        /etc/php5/fpm/php-fpm.conf
# centos 6.x
#    5.6
#        /etc/php-fpm.conf
#    5.5
#        /etc/php-fpm.conf
#    5.4
#        /etc/php-fpm.conf
#
define puphpet::php::fpm::ini (
  $fpm_version,
  $entry,
  $value  = '',
  $ensure = present,
  $php_fpm_service
  ) {

  $pool_name = 'global'

  case $fpm_version {
    '7.0', '70', '7': {
      $dir_name = 'php7'
    }
    default: {
      $dir_name = 'php5'
    }
  }

  case $::osfamily {
    'debian': {
      $pool_dir = "/etc/${dir_name}/fpm"
    }
    'redhat': {
      $pool_dir = '/etc'
    }
  }

  $conf_filename = "${pool_dir}/php-fpm.conf"

  $changes = $ensure ? {
    present => [ "set '${pool_name}/${entry}' '${value}'" ],
    absent  => [ "rm '${pool_name}/${entry}'" ],
  }

  augeas { "${pool_name}/${entry}: ${value}":
    lens    => 'PHP.lns',
    incl    => $conf_filename,
    changes => $changes,
    notify  => Service[$php_fpm_service],
  }

}
