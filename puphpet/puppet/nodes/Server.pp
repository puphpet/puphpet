class puphpet_server (
  $server
) {

  include ntp
  include swap_file

  each( ['puppet', 'www-data', 'www-user'] ) |$group| {
    if ! defined(Group[$group]) {
      group { $group:
        ensure => present
      }
    }
  }

  case $::ssh_username {
    'root': {
      $user_home   = '/root'
      $manage_home = false
    }
    default: {
      $user_home   = "/home/${::ssh_username}"
      $manage_home = true
    }
  }

  @user { $::ssh_username:
    ensure     => present,
    shell      => '/bin/bash',
    home       => $user_home,
    managehome => $manage_home,
    groups     => ['www-data', 'www-user'],
    require    => [Group['www-data'], Group['www-user']],
  }

  User[$::ssh_username]

  each( ['apache', 'nginx', 'httpd', 'www-data', 'www-user'] ) |$key| {
    if ! defined(User[$key]) {
      user { $key:
        ensure  => present,
        shell   => '/bin/bash',
        groups  => 'www-data',
        require => Group['www-data']
      }
    }
  }

  # copy dot files to ssh user's home directory
  exec { 'dotfiles':
    cwd     => $user_home,
    command => "cp -r /vagrant/puphpet/files/dot/.[a-zA-Z0-9]* ${user_home}/ && \
                chown -R ${::ssh_username} ${user_home}/.[a-zA-Z0-9]* && \
                cp -r /vagrant/puphpet/files/dot/.[a-zA-Z0-9]* /root/",
    onlyif  => 'test -d /vagrant/puphpet/files/dot',
    returns => [0, 1],
    require => User[$::ssh_username]
  }

  case $::osfamily {
    'debian': {
      include apt

      Class['apt::update'] -> Package <|
        title != 'python-software-properties' and
        title != 'software-properties-common'
      |>

      if ! defined(Package['augeas-tools']) {
        package { 'augeas-tools':
          ensure => present,
        }
      }
    }
    'redhat': {
      class { 'yum': extrarepo => ['epel'] }

      class { 'yum::repo::rpmforge': }
      class { 'yum::repo::repoforgeextras': }

      Class['::yum'] -> Yum::Managed_yumrepo <| |> -> Package <| |>

      if ! defined(Package['git']) {
        package { 'git':
          ensure  => latest,
          require => Class['yum::repo::repoforgeextras']
        }
      }

      if ! defined(Package['augeas']) {
        package { 'augeas':
          ensure => present,
        }
      }
    }
    default: {
      error('PuPHPet currently only works with Debian and RHEL families')
    }
  }

  case $::operatingsystem {
    'debian': {
      include apt::backports

      if ! defined(Apt::Source['packages.dotdeb.org-repo.puphpet']) {
        apt::source { 'packages.dotdeb.org-repo.puphpet':
          location          => 'http://repo.puphpet.com/dotdeb/',
          release           => $::lsbdistcodename,
          repos             => 'all',
          required_packages => 'debian-keyring debian-archive-keyring',
          key               => '89DF5277',
          key_server        => 'hkp://keyserver.ubuntu.com:80',
          include_src       => true
        }
      }

      $lsbdistcodename = downcase($::lsbdistcodename)

      apt::force { 'git':
        release => "${lsbdistcodename}-backports",
        timeout => 60
      }
    }
    'ubuntu': {
      if ! defined(Apt::Key['4F4EA0AAE5267A6C']){
        apt::key { '4F4EA0AAE5267A6C':
          key_server => 'hkp://keyserver.ubuntu.com:80'
        }
      }
      if ! defined(Apt::Key['4CBEDD5A']){
        apt::key { '4CBEDD5A':
          key_server => 'hkp://keyserver.ubuntu.com:80'
        }
      }

      if $::lsbdistcodename in ['lucid', 'precise'] {
        apt::ppa { 'ppa:pdoes/ppa':
          require => Apt::Key['4CBEDD5A'],
          options => ''
        }
      } else {
        apt::ppa { 'ppa:pdoes/ppa':
          require => Apt::Key['4CBEDD5A']
        }
      }
    }
    'redhat', 'centos': {
    }
    default: {
      error('PuPHPet supports Debian, Ubuntu, CentOS and RHEL only')
    }
  }

  each( $server['packages'] ) |$package| {
    if ! defined(Package[$package]) {
      package { $package:
        ensure => present,
      }
    }
  }

}
