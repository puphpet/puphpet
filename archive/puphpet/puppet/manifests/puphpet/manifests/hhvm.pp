# Class for installing HHVM
#
class puphpet::hhvm {

  include ::puphpet::params
  include ::puphpet::hhvm::params

  $hhvm = $puphpet::params::hiera['hhvm']

  class { 'puphpet::hhvm::install': }

  # config file could contain no server_ini key
  $server_inis = array_true($hhvm, 'server_ini') ? {
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
  $php_inis = array_true($hhvm, 'php_ini') ? {
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

  if array_true($hhvm, 'composer') and ! defined(Class['puphpet::php::composer']) {
    class { 'puphpet::php::composer':
      php_package   => 'hhvm',
      composer_home => $hhvm['composer_home'],
    }
  }

}
