class puphpet_mailcatcher (
  $mailcatcher
) {

  include puphpet::supervisord

  if ! defined(Package['tilt']) {
    package { 'tilt':
      ensure   => '1.3',
      provider => 'gem',
      before   => Class['mailcatcher']
    }
  }

  if $::operatingsystem == 'ubuntu' and $lsbdistcodename == 'trusty' {
    package { 'rubygems':
      ensure => absent,
    }
  }

  $settings = delete(
    $mailcatcher['settings'],
    'from_email_method'
  )

  create_resources('class', { 'mailcatcher' => $settings })

  if ! defined(Puphpet::Firewall::Port[$settings['smtp_port']]) {
    puphpet::firewall::port { $settings['smtp_port']: }
  }

  if ! defined(Puphpet::Firewall::Port[$settings['http_port']]) {
    puphpet::firewall::port { $settings['http_port']: }
  }

  $path = $settings['mailcatcher_path']

  $options = sort(join_keys_to_values({
    ' --smtp-ip'   => $settings['smtp_ip'],
    ' --smtp-port' => $settings['smtp_port'],
    ' --http-ip'   => $settings['http_ip'],
    ' --http-port' => $settings['http_port']
  }, ' '))

  supervisord::program { 'mailcatcher':
    command     => "${path}/mailcatcher ${options} -f",
    priority    => '100',
    user        => 'mailcatcher',
    autostart   => true,
    autorestart => 'true',
    environment => {
      'PATH' => "/bin:/sbin:/usr/bin:/usr/sbin:${path}"
    },
    require     => [
      Class['mailcatcher::config'],
      File['/var/log/mailcatcher']
    ],
  }

}
