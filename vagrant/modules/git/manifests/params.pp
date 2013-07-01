# = Class: git::params
#
# Configure how the puppet git module behaves

class git::params {

  case $::operatingsystem {
    'CentOS','Ubuntu', 'Debian', 'Amazon' :{
      $package      = 'git'
      $svn_package  = 'git-svn'
      $gui_package  = 'git-gui'
      $bin          = '/usr/bin/git'
    }
    default:{
      warning("git not configured for ${::operatingsystem} on ${::fqdn}")
    }
  }
}
