# This depends on maestrodev/rvm: https://github.com/maestrodev/puppet-rvm
# Requires $::ssh_username facter
# Sets up .rvmrc files in user home directories
define puphpet::server::link_dotfiles {

  $user_home = $name

  file_line { 'link ~/.bash_git':
    ensure  => present,
    line    => 'if [ -f ~/.bash_git ] ; then source ~/.bash_git; fi',
    path    => "${user_home}/.bash_profile",
    require => Exec['dotfiles'],
  }

  file_line { 'link ~/.bash_aliases':
    ensure  => present,
    line    => 'if [ -f ~/.bash_aliases ] ; then source ~/.bash_aliases; fi',
    path    => "${user_home}/.bash_profile",
    require => Exec['dotfiles'],
  }

  if $::ssh_username != 'root' {
    file_line { 'link ~/.bash_git for root':
      ensure  => present,
      line    => 'if [ -f ~/.bash_git ] ; then source ~/.bash_git; fi',
      path    => '/root/.bashrc',
      require => Exec['dotfiles'],
    }

    file_line { 'link ~/.bash_aliases for root':
      ensure  => present,
      line    => 'if [ -f ~/.bash_aliases ] ; then source ~/.bash_aliases; fi',
      path    => '/root/.bashrc',
      require => Exec['dotfiles'],
    }
  }

}
