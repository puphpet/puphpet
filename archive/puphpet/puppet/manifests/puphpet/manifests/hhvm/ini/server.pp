# Class for setting HHVM-specific INI flags
#
#  [*key*]
#    Flag name
#  [*value*]
#    Flag value
#  [*change_type*]
#    set, rm, clear, ins, mv
#
define puphpet::hhvm::ini::server (
  $key,
  $value,
  $change_type,
) {

  include ::puphpet::hhvm::params

  $ini_file = $puphpet::hhvm::params::server_ini
  $changes  = [ "${change_type} '${key}' '${value}'" ]

  augeas { "hhvm server_ini, ${key}: ${value}":
    lens    => 'PHP.lns',
    incl    => $ini_file,
    context => "/files${ini_file}/.anon",
    changes => $changes,
    notify  => Service[$puphpet::hhvm::params::service_name],
    require => Package[$puphpet::hhvm::params::package_name],
  }

}
