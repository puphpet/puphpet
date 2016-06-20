# == Class: puphpet::adminer::install
#
# Installs Adminer SQL gui tool.
# (Nginx or Apache) and PHP must be flagged for installation.
#
# Usage:
#
#  class { 'puphpet::adminer::install': }
#
class puphpet::adminer::install
  inherits puphpet::params
{

  include ::puphpet::nginx::params
  include ::puphpet::apache::params

  $nginx  = $puphpet::params::hiera['nginx']
  $apache = $puphpet::params::hiera['apache']

  if array_true($nginx, 'install') {
    $webroot = $puphpet::nginx::params::nginx_webroot_location
    $require = Class['puphpet::nginx']
  } elsif array_true($apache, 'install') {
    $webroot = $puphpet::apache::params::default_vhost_dir
    $require = Class['puphpet::apache::install']
  } else {
    fail('adminer requires either Apache or Nginx installed')
  }

  if ! defined(File[$webroot]) {
    file { $webroot:
      replace => no,
      ensure  => directory,
      mode    => '0775',
    }
  }

  if ! defined(Puphpet::Server::Wget["${webroot}/adminer.php"]) {
    puphpet::server::wget { "${webroot}/adminer.php":
      source  => 'http://www.adminer.org/latest.php',
      mode    => '644',
      require => [
        File[$webroot],
        $require
      ],
    }
  }

}
