# Git installer manifest
# DO NOT USE DIRECTLY
#
# Use this instead:
# include git
#
# or:
# class {'git':
#   svn => true,
#   gui => true,
#}

class git::install(
  $gui,
  $svn
){
  require git::params

  if ! defined(Package[$git::params::package]) {
    package{$git::params::package: ensure => installed}
  }

  if $svn {
    package{$git::params::svn_package: ensure => installed}
  } else {
    package{$git::params::svn_package: ensure => absent}
  }

  if $gui {
    package{$git::params::gui_package: ensure => installed}
  } else {
    package{$git::params::gui_package: ensure => absent}
  }

  $root_name    = "root on ${::fqdn}"
  $root_email   = "root@${::fqdn}"

  git::user{'root':}

}
