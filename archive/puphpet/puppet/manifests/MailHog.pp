class puphpet_mailhog (
  $mailhog
) {

  include puphpet::supervisord

  $settings = $mailhog['settings']

  $filename = $::architecture ? {
    'i386'   => 'MailHog_linux_386',
    'amd64'  => 'MailHog_linux_amd64',
    'x86_64' => 'MailHog_linux_amd64'
  }

  $url  = "https://github.com/mailhog/MailHog/releases/download/v0.1.8/${filename}"
  $path = $settings['path']
  $cmd  = "wget --quiet --tries=5 --connect-timeout=10 -O '${path}' ${url}"

  exec { "download ${url}":
    creates => $path,
    command => $cmd,
    timeout => 3600,
    path    => '/usr/bin',
  } ->
  file { $path:
    ensure => present,
    mode   => '+x',
  } ->
  user { 'mailhog':
    ensure     => present,
    shell      => '/bin/bash',
    managehome => false,
  }

  if ! defined(Puphpet::Firewall::Port["${settings['smtp_port']}"]) {
    puphpet::firewall::port { "${settings['smtp_port']}": }
  }

  if ! defined(Puphpet::Firewall::Port["${settings['http_port']}"]) {
    puphpet::firewall::port { "${settings['http_port']}": }
  }

  $options = sort(join_keys_to_values({
    ' -smtp-bind-addr' => "${settings['smtp_ip']}:${settings['smtp_port']}",
    ' -ui-bind-addr'   => "${settings['http_ip']}:${settings['http_port']}"
  }, ' '))

  supervisord::program { 'mailhog':
    command     => "${path} ${options}",
    priority    => '100',
    user        => 'mailhog',
    autostart   => true,
    autorestart => 'true',
    environment => {
      'PATH' => "/bin:/sbin:/usr/bin:/usr/sbin:${path}"
    },
    require     => File[$path],
  }

}
