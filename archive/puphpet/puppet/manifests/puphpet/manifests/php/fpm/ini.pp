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
#        /etc/php/7.0/fpm/php-fpm.conf
#    5.6
#        /etc/php/5.6/fpm/php-fpm.conf
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

  if $fpm_version in ['7.0', '70', '7'] {
    case $::operatingsystem {
      # Debian and Ubuntu slightly differ
      'debian': {
        $dir_name = 'php7'
      }
      'ubuntu': {
        $dir_name = 'php/7.0'
      }
      'redhat', 'centos': {
        $dir_name = 'php'
      }
    }
  } elsif $fpm_version in ['5.6', '56'] {
    case $::operatingsystem {
      'debian': {
        $dir_name = 'php5'
      }
      'ubuntu': {
        $dir_name = 'php/5.6'
      }
      'redhat', 'centos': {
        $dir_name = 'php5'
      }
    }
  } else {
    $dir_name = 'php5'
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

  if '=' in $value {
    $changes = $ensure ? {
      present => [ "set '${pool_name}/${entry}' \"'${value}'\"" ],
      absent  => [ "rm \"'${pool_name}/${entry}'\"" ],
    }
  } else {
    $changes = $ensure ? {
      present => [ "set '${pool_name}/${entry}' '${value}'" ],
      absent  => [ "rm \"'${pool_name}/${entry}'\"" ],
    }
  }

  augeas { "${pool_name}/${entry}: ${value}":
    lens    => 'PHP.lns',
    incl    => $conf_filename,
    changes => $changes,
    notify  => Service[$php_fpm_service],
  }

}
