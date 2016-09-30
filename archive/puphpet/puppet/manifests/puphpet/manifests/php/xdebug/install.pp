
class puphpet::php::xdebug::install
 inherits puphpet::php::xdebug::params {

  include ::puphpet::php::settings

  $xdebug = $puphpet::params::hiera['xdebug']
  $php    = $puphpet::params::hiera['php']

  $version  = $puphpet::php::settings::version

  $compile = $version ? {
    '5.6'   => true,
    '56'    => true,
    '70'    => true,
    default => false,
  }

  $xdebug_package = $::osfamily ? {
    'Debian' => "${puphpet::php::settings::prefix}xdebug",
    'Redhat' => "${puphpet::php::settings::pecl_prefix}xdebug"
  }

  if !$compile and ! defined(Package[$xdebug_package])
    and $puphpet::php::settings::enable_xdebug
  {
    package { 'xdebug':
      name    => $xdebug_package,
      ensure  => installed,
      require => Package[$puphpet::php::settings::fpm_package],
      notify  => Service[$puphpet::php::settings::service],
    }
  } elsif $puphpet::php::settings::enable_xdebug {
    include ::puphpet::php::xdebug::compile
  }

  # shortcut for xdebug CLI debugging
  if ! defined(File['/usr/bin/xdebug']) {
    file { '/usr/bin/xdebug':
      ensure  => present,
      mode    => '+x',
      source  => 'puppet:///modules/puphpet/xdebug_cli_alias.erb',
      require => Package[$puphpet::php::settings::fpm_package]
    }
  }

  each( $xdebug['settings'] ) |$key, $value| {
    puphpet::php::ini { $key:
      entry       => "XDEBUG/${key}",
      value       => $value,
      php_version => $version,
      webserver   => $puphpet::php::settings::service,
      notify      => Service[$puphpet::php::settings::service],
    }
  }

}
