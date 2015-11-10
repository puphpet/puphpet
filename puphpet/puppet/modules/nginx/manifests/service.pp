# Class: nginx::service
#
# This module manages NGINX service management and vhost rebuild
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class nginx::service(
  $configtest_enable = $nginx::configtest_enable,
  $service_restart   = $nginx::service_restart,
  $service_ensure    = $nginx::service_ensure,
) {

  $service_enable = $service_ensure ? {
    running => true,
    absent => false,
    stopped => false,
    'undef' => undef,
    default => true,
  }

  if $service_ensure == 'undef' {
    $service_ensure_real = undef
  } else {
    $service_ensure_real = $service_ensure
  }

  service { 'nginx':
    ensure     => $service_ensure_real,
    enable     => $service_enable,
    hasstatus  => true,
    hasrestart => true,
  }
  if $configtest_enable == true {
    Service['nginx'] {
      restart => $service_restart,
    }
  }
}
