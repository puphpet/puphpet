# Class for installing beanstalkd work queue
#
# If beanstalkd_console GUI chosen for install,
# Apache or Nginx and PHP or HHVM must also be chosen
#
class puphpet::beanstalkd {

  include ::puphpet::params
  include ::puphpet::nginx::params
  include ::puphpet::apache::params

  $beanstalkd = $puphpet::params::hiera['beanstalkd']

  # beanstalk_console requires Apache or Nginx
  if array_true($puphpet::params::hiera['nginx'], 'install') {
    $webroot = "${puphpet::nginx::params::nginx_webroot_location}/beanstalk_console"
  } elsif array_true($puphpet::params::hiera['apache'], 'install') {
    $webroot = "${puphpet::apache::params::default_vhost_dir}/beanstalk_console"
  } else {
    $webroot = false
  }

  # beanstalk_console requires PHP engine
  if array_true($puphpet::params::hiera['php'], 'install')
    or array_true($puphpet::params::hiera['hhvm'], 'install')
  {
    $php_installed = true
  } else {
    $php_installed = false
  }

  create_resources(beanstalkd::config, {
    'beanstalkd' => $beanstalkd['settings'],
  })

  if array_true($beanstalkd, 'beanstalk_console') and $webroot and $php_installed {
    class { 'puphpet::beanstalkd::console' :
      install_location => $webroot
    }
  }

}
