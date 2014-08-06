if $drush_values == undef { $drush_values = hiera_hash('drush', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }

include puphpet::params

if hash_key_equals($drush_values, 'install', 1) {
  if $drush_values['version'] != undef
    and (hash_key_equals($php_values, 'install', 1)
          or hash_key_equals($hhvm_values, 'install', 1))
    and (hash_key_equals($php_values, 'composer', 1)
          or hash_key_equals($hhvm_values, 'composer', 1))
  {
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
      revision => $drush_values['version'],
    } ->
    composer::exec { 'drush':
      cmd     => 'install',
      cwd     => $drush_location,
      require => Vcsrepo[$drush_location],
    } ->
    exec { 'first drush run':
      command => 'drush cache-clear drush',
      path    => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', $drush_location ],
    } ->
    file { 'symlink drush':
      ensure => link,
      path   => '/usr/bin/drush',
      target => "${drush_location}/drush",
    }
  }
}
