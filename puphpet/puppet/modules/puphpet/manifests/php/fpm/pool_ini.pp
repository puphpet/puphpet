# Defines where we can expect PHP-FPM ini files and paths to be located.
#
# debian 7.x
#    5.6
#        /etc/php5/fpm/pool.d/www.conf
#    5.5
#        /etc/php5/fpm/pool.d/www.conf
#    5.4
#        /etc/php5/fpm/pool.d/www.conf
# ubuntu 14.04
#    5.6
#        /etc/php5/fpm/pool.d/www.conf
#    5.5
#        /etc/php5/fpm/pool.d/www.conf
#    5.4
#        N/A
# ubuntu 12.04
#    5.6
#        N/A
#    5.5
#        /etc/php5/fpm/pool.d/www.conf
#    5.4
#        /etc/php5/fpm/pool.d/www.conf
# centos 6.x
#    5.6
#        /etc/php-fpm.d/www.conf
#    5.5
#        /etc/php-fpm.d/www.conf
#    5.4
#        /etc/php-fpm.d/www.conf
#
define puphpet::php::fpm::pool_ini (
  $fpm_version,
  $pool_name = 'www',
  $entry,
  $value     = '',
  $ensure    = present,
  $php_fpm_service
  ) {

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
      $pool_dir = "/etc/${dir_name}/fpm/pool.d"
    }
    'redhat': {
      $pool_dir = '/etc/php-fpm.d'
    }
  }

  $conf_filename = delete("${pool_dir}/${pool_name}.conf", ' ')

  $changes = $ensure ? {
    present => [ "set '${pool_name}/${entry}' '${value}'" ],
    absent  => [ "rm '${pool_name}/${entry}'" ],
  }

  if ! defined(File[$conf_filename]) {
    file { $conf_filename:
      replace => no,
      ensure  => present,
      notify  => Service[$php_fpm_service],
    }
  }

  if ! defined(File_line["[${pool_name}]"]) {
    file_line { "[${pool_name}]":
      path    => $conf_filename,
      line    => "[${pool_name}]",
      require => File[$conf_filename],
    }
  }

  augeas { "${pool_name}/${entry}: ${value}":
    lens    => 'PHP.lns',
    incl    => $conf_filename,
    changes => $changes,
    require => File_line["[${pool_name}]"],
    notify  => Service[$php_fpm_service],
  }

}
