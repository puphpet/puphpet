if $::osfamily == 'RedHat' {
  class { 'epel':
    before => Class['rvm'],
  }
}

class { 'rvm': }
