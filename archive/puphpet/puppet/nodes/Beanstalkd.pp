if $beanstalkd_values == undef { $beanstalkd_values = hiera_hash('beanstalkd', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }

include puphpet::params

if hash_key_equals($apache_values, 'install', 1) {
  $beanstalk_console_webroot_location = '/var/www/default/beanstalk_console'
} elsif hash_key_equals($nginx_values, 'install', 1) {
  $beanstalk_console_webroot_location = "${puphpet::params::nginx_webroot_location}/beanstalk_console"
} else {
  $beanstalk_console_webroot_location = undef
}

if hash_key_equals($php_values, 'install', 1) or hash_key_equals($hhvm_values, 'install', 1) {
  $beanstalkd_php_installed = true
} else {
  $beanstalkd_php_installed = false
}

if hash_key_equals($beanstalkd_values, 'install', 1) {
  create_resources(beanstalkd::config, { 'beanstalkd' => $beanstalkd_values['settings'] })

  if hash_key_equals($beanstalkd_values, 'beanstalk_console', 1)
    and $beanstalk_console_webroot_location != undef
    and $beanstalkd_php_installed
  {
    exec { 'delete-beanstalk_console-path-if-not-git-repo':
      command => "rm -rf ${beanstalk_console_webroot_location}",
      onlyif  => "test ! -d ${beanstalk_console_webroot_location}/.git"
    }

    vcsrepo { $beanstalk_console_webroot_location:
      ensure   => present,
      provider => git,
      source   => 'https://github.com/ptrofimov/beanstalk_console.git',
      require  => Exec['delete-beanstalk_console-path-if-not-git-repo']
    }

    file { "${beanstalk_console_webroot_location}/storage.json":
      ensure  => present,
      group   => 'www-data',
      mode    => 0775,
      require => Vcsrepo[$beanstalk_console_webroot_location]
    }
  }
}
