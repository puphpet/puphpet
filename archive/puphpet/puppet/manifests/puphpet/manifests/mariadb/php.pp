class puphpet::mariadb::php
 inherits puphpet::mariadb::params {

  $mariadb = $puphpet::params::hiera['mariadb']
  $php     = $puphpet::params::hiera['php']
  $hhvm    = $puphpet::params::hiera['hhvm']

  if array_true($php, 'install') {
    $php_package = 'php'
  } elsif array_true($hhvm, 'install') {
    $php_package = 'hhvm'
  } else {
    $php_package = false
  }

  if $php_package == 'php' {
    if $::osfamily == 'redhat' and $php['settings']['version'] == '53' {
      $php_module = 'mysql'
    } elsif $::lsbdistcodename == 'lucid' or $::lsbdistcodename == 'squeeze' {
      $php_module = 'mysql'
    } elsif $::osfamily == 'debian' and $php['settings']['version'] in ['7.0', '70'] {
      $php_module = 'mysql'
    } elsif $::operatingsystem == 'ubuntu' and $php['settings']['version'] in ['5.6', '56'] {
      $php_module = 'mysql'
    } else {
      $php_module = 'mysqlnd'
    }

    if ! defined(Puphpet::Php::Module[$php_module]) {
      puphpet::php::module { $php_module:
        service_autorestart => true,
      }
    }
  }

  if array_true($mariadb, 'adminer')
    and $php_package
    and ! defined(Class['puphpet::adminer::install'])
  {
    class { 'puphpet::adminer::install': }
  }

}
