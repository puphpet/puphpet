define puphpet::hhvm::inis {

  include ::puphpet::params

  # config file could contain no server_ini key
  $server_inis = array_true($puphpet::params::hiera['hhvm'], 'server_ini') ? {
    true    => $hhvm['server_ini'],
    default => { }
  }

  each( $server_inis ) |$key, $value| {
    puphpet::hhvm::ini::server { "hhvm ${key}: ${value}":
      key         => $key,
      value       => $value,
      change_type => 'set',
    }
  }

  # config file could contain no php_ini key
  $php_inis = array_true($puphpet::params::hiera['hhvm'], 'php_ini') ? {
    true    => $hhvm['php_ini'],
    default => { }
  }

  each( $php_inis ) |$key, $value| {
    puphpet::hhvm::ini::php { "hhvm-php ${key}: ${value}":
      key         => $key,
      value       => $value,
      change_type => 'set',
    }
  }

}
