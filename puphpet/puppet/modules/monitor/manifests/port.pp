#
define monitor::port (
  $port,
  $protocol,
  $target,
  $tool,
  $checksource  = '',
  $template     = '',
  $options_hash = {},
  $enable=true
  ) {

  $bool_enable=any2bool($enable)

  $real_checksource = $checksource ? {
    ''      => $target ? {
      'localhost' => 'local',
      '127.0.0.1' => 'local',
      default     => 'remote',
    },
    default => $checksource,
  }

  # Manage template
  $real_template = $template ? {
    ''      => undef,
    default => $template,
  }

  $ensure = $bool_enable ? {
    false => 'absent',
    true  => 'present',
  }

  $tcp_check_command = $real_checksource ? {
    local   => "check_nrpe!check_port_tcp!${target}!${port}",
    default => "check_tcp!${port}",
  }

  $udp_check_command = $real_checksource ? {
    local   => "check_nrpe!check_port_udp!${target}!${port}",
    default => "check_udp!${port}",
  }

  $check_command = $protocol ? {
    tcp => $tcp_check_command,
    udp => $udp_check_command,
  }

  if ($tool =~ /nagios/) {
    nagios::service { $name:
      ensure        => $ensure,
      template      => $real_template,
      check_command => $check_command,
      options_hash  => $options_hash,
    }
  }

  if ($tool =~ /icinga/) {
    icinga::service { $name:
      ensure        => $ensure,
      template      => $real_template,
      check_command => $check_command,
    }
  }

  $puppi_command = $protocol ? {
    'tcp' => "check_tcp -H ${target} -p ${port}" ,
    'udp' => "check_udp -H ${target} -p ${port}" ,
  }
  if ($tool =~ /puppi/) {
    puppi::check { $name:
      enable   => $bool_enable,
      hostwide => 'yes',
      command  => $puppi_command,
    }
  }
}
