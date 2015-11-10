# This depends on maestrodev/rvm: https://github.com/maestrodev/puppet-rvm
# Requires $::ssh_username facter
# Sets up .rvmrc files in user home directories
define puphpet::ruby::dotfile {

  if $::ssh_username != 'root' {
    file { "/home/${::ssh_username}/.rvmrc":
      ensure  => present,
      owner   => $::ssh_username,
      require => User[$::ssh_username]
    }
    file_line { 'rvm_autoupdate_flag=0 >> ~/.rvmrc':
      ensure  => present,
      line    => 'rvm_autoupdate_flag=0',
      path    => "/home/${::ssh_username}/.rvmrc",
      require => File["/home/${::ssh_username}/.rvmrc"],
    }
  }

  file { '/root/.rvmrc':
    ensure => present,
    owner  => 'root',
  }
  file_line { 'rvm_autoupdate_flag=0 >> /root/.rvmrc':
    ensure  => present,
    line    => 'rvm_autoupdate_flag=0',
    path    => '/root/.rvmrc',
    require => File['/root/.rvmrc'],
  }

}
