# = Define: php::module
#
# This define installs and configures php modules
#
# == Parameters
#
# [*version*]
#   Version to install.
#
# [*absent*]
#   true to ensure package isn't installed.
#
# [*notify_service*]
#   If you want to restart a service automatically when
#   the module is applied. Default: true
#
# [*service_autorestart*]
#   whatever we want a module installation notify a service to restart.
#
# [*service*]
#   Service to restart.
#
# [*module_prefix*]
#   If package name prefix isn't standard.
#
# == Examples
# php::module { 'gd': }
#
# php::module { 'gd':
#   ensure => absent,
# }
#
# Note that you may include or declare the php class when using
# the php::module define
#
define php::module (
  $version             = $php::version,
  $service_autorestart = $php::bool_service_autorestart,
  $service             = $php::service,
  $absent              = $php::absent
  ) {

  if $absent {
    $real_version = "absent"
  } else {
    $real_version = $version
  }

  $manage_service_autorestart = $service_autorestart ? {
    true    => "Service[${service}]",
    false   => undef,
  }

  package { "PhpModule_${name}":
    ensure  => $real_version,
    name    => $name,
    notify  => $manage_service_autorestart,
    require => Package['php'],
  }

}
