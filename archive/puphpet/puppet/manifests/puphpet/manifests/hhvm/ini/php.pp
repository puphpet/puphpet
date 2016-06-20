# == Define Resource Type: puphpet::hhvm::ini::php
#
# Sets PHP-specific HHVM INI flags.
#
# Usage:
#
# puphpet::hhvm::ini::php { 'name' :
#   key         => 'display_errors',
#   value       => 'On',
#   change_type => 'set'
# }
#
# Parameters:
#
#  [*key*]
#    Flag name
#  [*value*]
#    Flag value
#  [*change_type*]
#    set, rm, clear, ins, mv
#
define puphpet::hhvm::ini::php (
  $key,
  $value,
  $change_type,
) {

  include ::puphpet::hhvm::params

  $ini_file = $puphpet::hhvm::params::php_ini
  $changes  = [ "${change_type} '${key}' '${value}'" ]

  augeas { "hhvm php_ini, ${key}: ${value}":
    lens    => 'PHP.lns',
    incl    => $ini_file,
    context => "/files${ini_file}/.anon",
    changes => $changes,
    notify  => Service[$puphpet::hhvm::params::service_name],
    require => Package[$puphpet::hhvm::params::package_name],
  }

}
