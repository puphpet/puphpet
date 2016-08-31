# Class: apt::unattended_upgrades
#
# This class manages the unattended-upgrades package and related configuration
# files for ubuntu
#
# origins are the repositories to automatically upgrade included packages
# blacklist is a list of packages to not automatically upgrade
# update is how often to run "apt-get update" in days
# download is how often to run "apt-get upgrade --download-only" in days
# upgrade is how often to upgrade packages included in the origins list in days
# autoclean is how often to run "apt-get autoclean" in days
#
# information on the other options can be found in the 50unattended-upgrades
# file and in /etc/cron.daily/apt
#
class apt::unattended_upgrades (
  $legacy_origin       = $::apt::params::legacy_origin,
  $origins             = $::apt::params::origins,
  $blacklist           = [],
  $update              = '1',
  $download            = '1',
  $upgrade             = '1',
  $autoclean           = '7',
  $auto_fix            = true,
  $minimal_steps       = false,
  $install_on_shutdown = false,
  $mail_to             = 'NONE',
  $mail_only_on_error  = false,
  $remove_unused       = true,
  $auto_reboot         = false,
  $dl_limit            = 'NONE',
  $randomsleep         = undef,
  $enable              = '1',
  $backup_interval     = '0',
  $backup_level        = '3',
  $max_age             = '0',
  $min_age             = '0',
  $max_size            = '0',
  $download_delta      = '0',
  $verbose             = '0',
) inherits ::apt::params {

  validate_bool(
    $legacy_origin,
    $auto_fix,
    $minimal_steps,
    $install_on_shutdown,
    $mail_only_on_error,
    $remove_unused,
    $auto_reboot
  )
  validate_array($origins)

  if $randomsleep {
    unless is_numeric($randomsleep) {
      fail('randomsleep must be numeric')
    }
  }

  package { 'unattended-upgrades':
    ensure => present,
  }

  file { '/etc/apt/apt.conf.d/50unattended-upgrades':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('apt/_header.erb', 'apt/50unattended-upgrades.erb'),
    require => Package['unattended-upgrades'],
  }

  file { '/etc/apt/apt.conf.d/10periodic':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('apt/_header.erb', 'apt/10periodic.erb'),
    require => Package['unattended-upgrades'],
  }
}
