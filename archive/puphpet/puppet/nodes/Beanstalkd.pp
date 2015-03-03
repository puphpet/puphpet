if $beanstalkd_values == undef { $beanstalkd_values = hiera_hash('beanstalkd', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }

include puphpet::params

# beanstalk_console requires Apache or Nginx
if hash_key_equals($apache_values, 'install', 1) {
  $beanstalk_console_webroot =
    "${puphpet::params::apache_webroot_location}/beanstalk_console"
} elsif hash_key_equals($nginx_values, 'install', 1) {
  $beanstalk_console_webroot =
    "${puphpet::params::nginx_webroot_location}/beanstalk_console"
} else {
  $beanstalk_console_webroot = undef
}

# beanstalk_console requires PHP engine
if hash_key_equals($php_values, 'install', 1)
  or hash_key_equals($hhvm_values, 'install', 1)
{
  $beanstalkd_php_installed = true
} else {
  $beanstalkd_php_installed = false
}

if hash_key_equals($beanstalkd_values, 'install', 1) {
  create_resources(beanstalkd::config, {
    'beanstalkd' => $beanstalkd_values['settings'],
  })

  # requires webserver and PHP engine
  if hash_key_equals($beanstalkd_values, 'beanstalk_console', 1)
    and $beanstalk_console_webroot != undef
    and $beanstalkd_php_installed
  {
    class { 'puphpet::beanstalkd::console' :
      install_location => $beanstalk_console_webroot
    }
  }
}
