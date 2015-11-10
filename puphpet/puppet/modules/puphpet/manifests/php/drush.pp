# This depends on puppetlabs-vcsrepo: https://github.com/puppetlabs/puppetlabs-vcsrepo.git
# This depends on puppet-composer: https://github.com/tPl0ch/puppet-composer
# Installs drush system wide
class puphpet::php::drush(
  $version
) {

    $drush_github   = 'https://github.com/drush-ops/drush.git'
    $drush_location = '/usr/share/drush'

    exec { 'delete-drush-path-if-not-git-repo':
      command => "rm -rf ${drush_location}",
      onlyif  => "test ! -d ${drush_location}/.git",
      path    => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
    } ->
    vcsrepo { $drush_location:
      ensure   => present,
      provider => git,
      source   => $drush_github,
      revision => $version,
    } ->
    composer::exec { 'drush':
      cmd     => 'install',
      cwd     => $drush_location,
      require => Vcsrepo[$drush_location],
    } ->
    exec { 'first drush run':
      command => 'drush cache-clear drush',
      path    => [
        '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', $drush_location
      ],
    } ->
    file { 'symlink drush':
      ensure => link,
      path   => '/usr/bin/drush',
      target => "${drush_location}/drush",
    }

}
