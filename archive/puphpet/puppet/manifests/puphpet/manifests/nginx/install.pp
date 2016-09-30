# == Class: puphpet::nginx::install
#
# Installs Nginx.
#
# Usage:
#
#  class { 'puphpet::nginx::install': }
#
class puphpet::nginx::install
 inherits puphpet::nginx::params {

  include ::nginx::params

  $nginx = $puphpet::params::hiera['nginx']

  $settings = $nginx['settings']

  Class['puphpet::ssl_cert']
  -> Nginx::Resource::Vhost <| |>

  class { 'puphpet::nginx::ssl_cert': }

  if ! defined(File[$puphpet::nginx::params::www_location]) {
    file { $puphpet::nginx::params::www_location:
      ensure  => directory,
      owner   => 'root',
      group   => $puphpet::nginx::params::webroot_group,
      mode    => '0775',
      before  => Class['nginx'],
      require => Group[$puphpet::nginx::params::webroot_group],
    }
  }

  if $::osfamily == 'redhat' {
    file { '/usr/share/nginx':
      ensure  => directory,
      mode    => '0775',
      owner   => $puphpet::nginx::params::webroot_user,
      group   => $puphpet::nginx::params::webroot_group,
      require => Group[$puphpet::nginx::params::webroot_group],
      before  => Package['nginx']
    }
  }

  create_resources('class', { 'nginx' => delete(merge({},
    $nginx['settings']), 'default_vhost')
  })

  # config file could contain no upstreams key
  $upstreams = array_true($nginx, 'upstreams') ? {
    true    => $nginx['upstreams'],
    default => { }
  }

  puphpet::nginx::upstreams { 'from puphpet::nginx::install':
    upstreams => $upstreams,
  }

  # config file could contain no proxies key
  $proxies = array_true($nginx, 'proxies') ? {
    true    => $nginx['proxies'],
    default => [ ],
  }

  puphpet::nginx::proxies { 'from puphpet::nginx::install':
    proxies => $proxies,
  }

  # config file could contain no vhosts key
  $vhosts_tmp = array_true($nginx, 'vhosts') ? {
    true    => $nginx['vhosts'],
    default => [ ],
  }

  # Creates a default vhost entry if user chose to do so
  if array_true($nginx['settings'], 'default_vhost') {
    $vhosts = merge($vhosts_tmp, {
      '_' => $puphpet::nginx::params::default_vhost,
    })

    # Force nginx to be managed exclusively through puppet module
    if ! defined(File[$puphpet::nginx::params::default_conf_location]) {
      file { $puphpet::nginx::params::default_conf_location:
        ensure  => absent,
        require => Package['nginx'],
        notify  => Class['nginx::service'],
      }
    }
  } else {
    $vhosts = $vhosts_tmp
  }

  puphpet::nginx::vhosts { 'from puphpet::nginx::install':
    vhosts => $vhosts,
  }

  if ! defined(Puphpet::Firewall::Port['443']) {
    puphpet::firewall::port { '443': }
  }

}
