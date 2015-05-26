class puphpet_xdebug (
  $xdebug,
  $php
) {

  Class['Puphpet::Php::Settings']
  -> Class['Puphpet::Php::Xdebug']

  $version = $php['settings']['version']
  $service = $puphpet::php::settings::service

  $compile = $version ? {
    '5.6'   => true,
    '56'    => true,
    default => false,
  }

  class { 'puphpet::php::xdebug':
    webserver => $service,
    compile   => $compile,
  }

  each( $xdebug['settings'] ) |$key, $value| {
    puphpet::php::ini { $key:
      entry       => "XDEBUG/${key}",
      value       => $value,
      php_version => $version,
      webserver   => $service,
      notify      => Service[$service],
    }
  }

}
