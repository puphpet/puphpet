if $xdebug_values == undef { $xdebug_values = hiera_hash('xdebug', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }

include puphpet::params

if hash_key_equals($xdebug_values, 'install', 1)
  and hash_key_equals($php_values, 'install', 1)
{
  Class['Puphpet::Php::Settings']
  -> Class['Puphpet::Php::Xdebug']

  $xdebug_compile = $php_values['settings']['version'] ? {
    '5.6'   => true,
    '56'    => true,
    default => false,
  }

  class { 'puphpet::php::xdebug':
    webserver => $puphpet::php::settings::service,
    compile   => $xdebug_compile,
  }

  each( $xdebug_values['settings'] ) |$key, $value| {
    puphpet::php::ini { $key:
      entry       => "XDEBUG/${key}",
      value       => $value,
      php_version => $php_values['settings']['version'],
      webserver   => $puphpet::php::settings::service
    }
  }
}
