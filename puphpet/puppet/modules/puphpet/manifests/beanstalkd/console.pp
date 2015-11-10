# This depends on puppetlabs-vcsrepo: https://github.com/puppetlabs/puppetlabs-vcsrepo.git
# This depends on puppet-beanstalkd: https://github.com/puphpet/puppet-beanstalkd
# This depends on puppet-composer: https://github.com/tPl0ch/puppet-composer
# Installs beanstalk_console from https://github.com/ptrofimov/beanstalk_console
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
