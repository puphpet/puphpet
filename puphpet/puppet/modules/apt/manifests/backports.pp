# This adds the necessary components to get backports for ubuntu and debian
#
# == Parameters
#
# [*release*]
#   The ubuntu/debian release name. Defaults to $lsbdistcodename. Setting this
#   manually can cause undefined behavior. (Read: universe exploding)
#
# [*pin_priority*]
#   _default_: 200
#
#   The priority that should be awarded by default to all packages coming from
#   the Debian Backports project.
#
# == Examples
#
#   include apt::backports
#
#   class { 'apt::backports':
#     release => 'natty',
#   }
#
# == Authors
#
# Ben Hughes, I think. At least blame him if this goes wrong.
# I just added puppet doc.
#
# == Copyright
#
# Copyright 2011 Puppet Labs Inc, unless otherwise noted.
class apt::backports(
  $release      = $::lsbdistcodename,
  $location     = $::apt::params::backports_location,
  $pin_priority = 200,
) inherits apt::params {

  if ! is_integer($pin_priority) {
    fail('$pin_priority must be an integer')
  }

  if $::lsbdistid == 'LinuxMint' {
    if $::lsbdistcodename == 'debian' {
      $distid = 'debian'
      $release_real = 'wheezy'
    } else {
      $distid = 'ubuntu'
      $release_real = $::lsbdistcodename ? {
        'qiana'  => 'trusty',
        'petra'  => 'saucy',
        'olivia' => 'raring',
        'nadia'  => 'quantal',
        'maya'   => 'precise',
      }
    }
  } else {
    $distid = $::lsbdistid
    $release_real = downcase($release)
  }

  $key = $distid ? {
    'debian' => 'A1BD8E9D78F7FE5C3E65D8AF8B48AD6246925553',
    'ubuntu' => '630239CC130E1A7FD81A27B140976EAF437D05B5',
  }
  $repos = $distid ? {
    'debian' => 'main contrib non-free',
    'ubuntu' => 'main universe multiverse restricted',
  }

  apt::pin { 'backports':
    before   => Apt::Source['backports'],
    release  => "${release_real}-backports",
    priority => $pin_priority,
  }

  apt::source { 'backports':
    location   => $location,
    release    => "${release_real}-backports",
    repos      => $repos,
    key        => $key,
    key_server => 'pgp.mit.edu',
  }
}
