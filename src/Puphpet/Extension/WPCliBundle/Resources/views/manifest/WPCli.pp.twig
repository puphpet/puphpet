if $wpcli_values == undef { $wpcli_values = hiera_hash('wpcli', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }

include puphpet::params

if hash_key_equals($wpcli_values, 'install', 1) {
  if $wpcli_values['version'] != undef
    and (hash_key_equals($php_values, 'install', 1)
          or hash_key_equals($hhvm_values, 'install', 1))
    and (hash_key_equals($php_values, 'composer', 1)
          or hash_key_equals($hhvm_values, 'composer', 1))
  {
    $wpcli_github   = 'https://github.com/wp-cli/wp-cli.git'
    $wpcli_location = '/usr/share/wp-cli'

    exec { 'delete-wpcli-path-if-not-git-repo':
      command => "rm -rf ${wpcli_location}",
      onlyif  => "test ! -d ${wpcli_location}/.git",
      path    => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
    } ->
    vcsrepo { $wpcli_location:
      ensure   => present,
      provider => git,
      source   => $wpcli_github,
      revision => $wpcli_values['version'],
    } ->
    composer::exec { 'wp-cli':
      cmd     => 'install',
      cwd     => $wpcli_location,
      require => Vcsrepo[$wpcli_location],
    } ->
    file { "${wpcli_location}/bin/wp":
      ensure => present,
      mode   => '+x',
    }
    file { 'symlink wp-cli':
      ensure => link,
      path   => '/usr/bin/wp',
      mode   => 0766,
      target => "${wpcli_location}/bin/wp",
    }
  }
}
