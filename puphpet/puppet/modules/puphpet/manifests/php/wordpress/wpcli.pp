# This depends on puppetlabs-vcsrepo: https://github.com/puppetlabs/puppetlabs-vcsrepo.git
# This depends on puppet-composer: https://github.com/tPl0ch/puppet-composer.git
# Installs WPCLI system-wide
class puphpet::php::wordpress::wpcli (
  $version
) {

  $github   = 'https://github.com/wp-cli/wp-cli.git'
  $location = '/usr/share/wp-cli'

  exec { 'delete-wpcli-path-if-not-git-repo':
    command => "rm -rf ${location}",
    onlyif  => "test ! -d ${location}/.git",
    path    => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
  } ->
  vcsrepo { $location:
    ensure   => present,
    provider => git,
    source   => $github,
    revision => $version,
  } ->
  composer::exec { 'wp-cli':
    cmd     => 'install',
    cwd     => $location,
    require => Vcsrepo[$location],
  } ->
  file { "${location}/bin/wp":
    ensure => present,
    mode   => '+x',
  }
  file { 'symlink wp-cli':
    ensure => link,
    path   => '/usr/bin/wp',
    mode   => '0766',
    target => "${location}/bin/wp",
  }

}
