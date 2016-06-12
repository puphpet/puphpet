# Class for installing mailhog smtp server
#
class puphpet::mailhog {

  include ::puphpet::params
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

  class { 'puphpet::mailhog::install':
    install_path => $path,
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
    require     => Class['puphpet::mailhog::install'],
  }

}
