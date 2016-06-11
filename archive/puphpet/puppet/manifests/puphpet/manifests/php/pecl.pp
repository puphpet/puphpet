/*
 * This "translates" PECL package names into system-specific names.
 * For example, APCu does not install correctly on CentOS via PECL,
 * but there is a system package for it that works well. Use that
 * instead of the PECL package.
 */

define puphpet::php::pecl (
  $service_autorestart,
  $prefix = $puphpet::php::settings::pecl_prefix
){

  $ignore = {
    'date_time' => true,
    'mysql'     => true,
  }

  $pecl = $::osfamily ? {
    'Debian' => {
      'mongo' => 'mongodb',
    },
    'Redhat' => {
      'mongo' => 'mongodb',
    }
  }

  $pecl_beta = $::osfamily ? {
    'Debian' => {
      'amqp'          => 'amqp',
      'augeas'        => 'augeas',
      'mcrypt_filter' => 'mcrypt_filter',
      'pdo_user'      => 'pdo_user',
      'zendopcache'   => $::operatingsystem ? {
        'debian' => false,
        'ubuntu' => 'ZendOpcache',
      },
    },
    'Redhat' => {
      'amqp' => 'amqp',
    }
  }

  $package = $::osfamily ? {
    'Debian' => {
      'apc'         => $::operatingsystem ? {
        'debian' => "${prefix}apc",
        'ubuntu' => "${prefix}apcu",
      },
      'apcu'        => "${prefix}apcu",
      'imagick'     => "${prefix}imagick",
      'memcache'    => "${prefix}memcache",
      'memcached'   => "${prefix}memcached",
      'redis'       => $puphpet::php::settings::version ? {
        '54'    => false,
        '5.4'   => false,
        default => "${prefix}redis",
      },
      'sqlite'      => "${prefix}sqlite",
      'zendopcache' => "${prefix}zendopcache",
    },
    'Redhat' => {
      'amqp'        => "${prefix}amqp",
      'apc'         => $puphpet::php::settings::version ? {
        '53'    => "${prefix}apc",
        '5.3'   => "${prefix}apc",
        default => "${prefix}apcu",
      },
      'apcu'        => "${prefix}apcu",
      'imagick'     => "${prefix}imagick",
      'memcache'    => "${prefix}memcache",
      'memcached'   => "${prefix}memcached",
      'redis'       => "${prefix}redis",
      'sqlite'      => "${prefix}sqlite",
      'zendopcache' => "${prefix}zendopcache",
    }
  }

  $auto_answer_hash = {
    #
  }

  $downcase_name = downcase($name)

  if has_key($auto_answer_hash, $downcase_name) {
    $auto_answer = $auto_answer_hash[$downcase_name]
  } else {
    $auto_answer = '\\n'
  }

  if has_key($ignore, $downcase_name) and $ignore[$downcase_name] {
    $pecl_name       = $pecl[$downcase_name]
    $package_name    = false
    $preferred_state = 'stable'
  }
  elsif has_key($pecl, $downcase_name) and $pecl[$downcase_name] {
    $pecl_name       = $pecl[$downcase_name]
    $package_name    = false
    $preferred_state = 'stable'
  }
  elsif has_key($pecl_beta, $downcase_name) and $pecl_beta[$downcase_name] {
    $pecl_name       = $pecl_beta[$downcase_name]
    $package_name    = false
    $preferred_state = 'beta'
  }
  elsif has_key($package, $downcase_name) and $package[$downcase_name] {
    $pecl_name    = false
    $package_name = $package[$downcase_name]
  }
  else {
    $pecl_name    = $name
    $package_name = false
  }

  if $pecl_name and ! defined(Php::Pecl::Module[$pecl_name])
    and $puphpet::php::settings::enable_pecl
  {
    ::php::pecl::module { $pecl_name:
      use_package         => false,
      preferred_state     => $preferred_state,
      auto_answer         => $auto_answer,
      service_autorestart => $service_autorestart,
    }

    if ! defined(Puphpet::Php::Ini[$pecl_name]) {
      puphpet::php::ini { $pecl_name:
        entry        => 'MODULE/extension',
        value        => "${pecl_name}.so",
        php_version  => $puphpet::php::settings::version,
        webserver    => $puphpet::php::settings::service,
        ini_filename => "${pecl_name}.ini",
      }
    }
  }
  elsif $package_name and ! defined(Package[$package_name])
    and $puphpet::php::settings::enable_pecl
  {
    package { $package_name:
      ensure  => present,
      require => Package[$puphpet::php::settings::package_devel]
    }
  }

}
