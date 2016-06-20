# == Class: puphpet::drush::install
#
# Installs Drush CLI tool.
# (PHP or HHVM) and Composer must be flagged for installation.
#
# Usage:
#
#  class { 'puphpet::drush::install': }
#
class puphpet::drush::install
  inherits puphpet::params
{

  $drush = $puphpet::params::hiera['drush']
  $php   = $puphpet::params::hiera['php']
  $hhvm  = $puphpet::params::hiera['hhvm']

  $version  = $drush['version'] != undef
  $engine   = (array_true($php, 'install') or array_true($hhvm, 'install'))
  $composer = (array_true($php, 'composer') or array_true($hhvm, 'composer'))

  if !$engine {
    info('Drush not installed: PHP or HHVM not selected')
  }

  if !$composer {
    info('Drush not installed: Composer not selected')
  }

  # Requires either PHP or HHVM, and Composer
  if $version and $engine and $composer {
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
      dev     => false,
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

}
