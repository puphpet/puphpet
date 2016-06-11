class puphpet::php::settings (
  $version_string
){

  if $version_string == '7.0' or $version_string == '70' {
    $version = '70'
  } else {
    $version = $version_string
  }

  $enable_modules = true
  $enable_pear    = true
  $enable_pecl    = true
  $enable_xdebug  = true

  if $version == '70' {
    $prefix = $::osfamily ? {
      'debian' => $::operatingsystem ? {
        'ubuntu' => 'php7.0-',
        'debian' => 'php7-'
      },
      'redhat' => 'php-'
    }

    $pecl_prefix = $::osfamily ? {
      'debian' => $::operatingsystem ? {
        'ubuntu' => 'php-',
        'debian' => 'php7-'
      },
      'redhat' => 'php70-php-pecl-'
    }

    $cli_package = "${prefix}cli"
    $fpm_package = "${prefix}fpm"
    $service     = "${prefix}fpm"

    $package_devel = $::osfamily ? {
      'debian' => 'php7.0-dev',
      'redhat' => 'php-devel',
    }

    $base_ini = $::osfamily ? {
      'debian' => '/etc/php/7.0/php.ini',
      'redhat' => '/etc/php.ini',
    }

    $fpm_ini = $::osfamily ? {
      'debian' => '/etc/php/7.0/fpm/php.ini',
      'redhat' => '/etc/php.ini',
    }

    $pid_file = $::osfamily ? {
      'debian' => '/run/php-fpm.pid',
      'redhat' => '/var/run/php-fpm.pid',
    }
  }

  elsif $version in ['56', '5.6'] {
    $prefix = $::osfamily ? {
      'debian' => $::operatingsystem ? {
        'ubuntu' => 'php5.6-',
        default  => 'php5-'
      },
      'redhat' => 'php-'
    }

    $pecl_prefix = $::osfamily ? {
      'debian' => 'php5-',
      'redhat' => 'php-pecl-',
    }

    $cli_package = "${prefix}cli"
    $fpm_package = "${prefix}fpm"
    $service     = "${prefix}fpm"

    $package_devel = $::osfamily ? {
      'debian' => $::operatingsystem ? {
        'ubuntu' => "${prefix}dev",
        default  => $php::params::package_devel,
      },
      'redhat' => $php::params::package_devel
    }

    $base_ini = $::osfamily ? {
      'debian' => $::operatingsystem ? {
        'ubuntu' => '/etc/php/5.6/php.ini',
        default  => '/etc/php5/php.ini'
      },
      'redhat' => '/etc/php.ini',
    }

    $fpm_ini = $::osfamily ? {
      'debian' => $::operatingsystem ? {
        'ubuntu' => '/etc/php/5.6/fpm/php.ini',
        default  => '/etc/php5/fpm/php.ini',
      },
      'redhat' => '/etc/php.ini',
    }

    $pid_file = $::osfamily ? {
      'debian' => '/run/php-fpm.pid',
      'redhat' => '/var/run/php-fpm/php-fpm.pid',
    }
  }

  elsif $version in ['55', '5.5', '54', '5.4'] {
    $prefix = $::osfamily ? {
      'debian' => 'php5-',
      'redhat' => 'php-'
    }

    $pecl_prefix = $::osfamily ? {
      'debian' => 'php5-',
      'redhat' => 'php-pecl-',
    }

    $cli_package = "${prefix}cli"
    $fpm_package = "${prefix}fpm"
    $service     = "${prefix}fpm"

    $package_devel = $php::params::package_devel

    $base_ini = $::osfamily ? {
      'debian' => '/etc/php5/php.ini',
      'redhat' => '/etc/php.ini',
    }

    $fpm_ini = $::osfamily ? {
      'debian' => '/etc/php5/fpm/php.ini',
      'redhat' => '/etc/php.ini',
    }

    $pid_file = $::osfamily ? {
      'debian' => '/run/php-fpm.pid',
      'redhat' => '/var/run/php-fpm/php-fpm.pid',
    }
  }

  # 5.3, only rhel
  else {
    $prefix = $::osfamily ? {
      'redhat' => 'php53u-',
    }

    $pecl_prefix = $::osfamily ? {
      'redhat' => 'php53u-pecl-',
    }

    $cli_package = "${prefix}cli"
    $fpm_package = "${prefix}fpm"
    $service     = 'php-fpm'

    $package_devel = $::osfamily ? {
      'redhat' => 'php53u-devel',
    }

    $base_ini = $::osfamily ? {
      'redhat' => '/etc/php.ini',
    }

    $fpm_ini = $::osfamily ? {
      'redhat' => '/etc/php.ini',
    }

    $pid_file = $::osfamily ? {
      'redhat' => '/var/run/php-fpm/php-fpm.pid',
    }
  }

  Package[$fpm_package]
  -> Puphpet::Php::Module <| |>

  Package[$fpm_package]
  -> Puphpet::Php::Pear <| |>

  Package[$fpm_package]
  -> Puphpet::Php::Pecl <| |>

  Package[$fpm_package]
  -> Puphpet::Php::Ini <| |>

  Package[$fpm_package]
  -> Puphpet::Php::Fpm::Ini <| |>

  Package[$fpm_package]
  -> Puphpet::Php::Fpm::Pool_ini <| |>

}
