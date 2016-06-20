# == Class: puphpet::mailhog::install
#
# Installs mailhog smtp server.
#
# Usage:
#
#  class { 'puphpet::mailhog::install': }
#
class puphpet::mailhog::install
 inherits puphpet::mailhog::params {

  include ::puphpet::supervisord

  $mailhog = $puphpet::params::hiera['mailhog']

  $settings = $mailhog['settings']
  $path     = $settings['path']

  if ! defined(Puphpet::Firewall::Port["${settings['smtp_port']}"]) {
    puphpet::firewall::port { "${settings['smtp_port']}": }
  }

  if ! defined(Puphpet::Firewall::Port["${settings['http_port']}"]) {
    puphpet::firewall::port { "${settings['http_port']}": }
  }

  group { $puphpet::mailhog::params::group:
    ensure => present,
  }

  user { $puphpet::mailhog::params::user:
    ensure     => present,
    groups     => [$puphpet::mailhog::params::group],
    managehome => false,
    shell      => '/bin/bash',
    require    => Group[$puphpet::mailhog::params::group],
  }

  puphpet::server::wget { $puphpet::mailhog::params::install_path:
    source => $puphpet::mailhog::params::download_url,
    user   => 'root',
    group  => 'root',
    mode   => '+x'
  }

  $options = join([
    "-smtp-bind-addr ${settings['smtp_ip']}:${settings['smtp_port']}",
    "-ui-bind-addr ${settings['http_ip']}:${settings['http_port']}",
  ], ' ')

  supervisord::program { 'mailhog':
    command     => "${path} ${options}",
    priority    => '100',
    user        => 'mailhog',
    autostart   => true,
    autorestart => 'true',
    environment => {
      'PATH' => "/bin:/sbin:/usr/bin:/usr/sbin:${path}"
    },
    require     => Puphpet::Server::Wget[$puphpet::mailhog::params::install_path],
  }

}
