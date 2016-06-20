# == Class: puphpet::beanstalkd::console
#
# Downloads beanstalkd_console.
#
# Usage:
#
# class { 'puphpet::beanstalkd::console':
#   install_location => '/path/to/webroot'
# }
#
class puphpet::beanstalkd::console(
  $install_location
) {

  exec { 'delete-beanstalk_console-path-if-not-git-repo':
    command => "rm -rf ${install_location}",
    onlyif  => "test ! -d ${install_location}/.git"
  }

  vcsrepo { $install_location:
    ensure   => present,
    provider => git,
    source   => 'https://github.com/ptrofimov/beanstalk_console.git',
    require  => Exec['delete-beanstalk_console-path-if-not-git-repo']
  }

  file { "${install_location}/storage.json":
    ensure  => present,
    group   => 'www-data',
    mode    => '0775',
    require => Vcsrepo[$install_location]
  }

}
