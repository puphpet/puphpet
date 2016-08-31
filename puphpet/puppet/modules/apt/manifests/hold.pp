# == Define apt::hold
#
# This defined type allows you to hold a package based on the version you
# require. It's implemented by dropping an apt preferences file pinning the
# package to the version you require.
#
# === Parameters
#
# [*version*]
#   The version at which you wish to pin a package.
#
#   This can either be the full version, such as 4:2.11.8.1-5, or
#   a partial version, such as 4:2.11.*
#
# [*package*]
#   _default_: +$title+, the title/name of the resource.
#
#   Name of the package that apt is to hold.
#
# [*priority*]
#   _default_: +1001+
#
#   The default priority of 1001 causes this preference to always win. By
#   setting the priority to a number greater than 1000 apt will always install
#   this version even if it means downgrading the currently installed version.
define apt::hold(
  $version,
  $ensure   = 'present',
  $package  = $title,
  $priority = 1001,
){

  validate_string($title)
  validate_re($ensure, ['^present|absent',])
  validate_string($package)
  validate_string($version)

  if ! is_integer($priority) {
    fail('$priority must be an integer')
  }

  if $ensure == 'present' {
    ::apt::pin { "hold_${package}":
      packages => $package,
      version  => $version,
      priority => $priority,
    }
  } else {
    ::apt::pin { "hold_${package}":
      ensure => 'absent',
    }
  }

}
