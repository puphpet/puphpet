#
define monitor::process (
  $tool,
  $process             = $name,
  $service             = undef,
  $service_description = undef,
  $pidfile             = '',
  $enable              = true,
  $argument            = '',
  $user                = '',
  $template            = '',
  $config_hash         = {}
  ) {

  $bool_enable=any2bool($enable)

  $real_template = $template ? {
    ''      => undef,
    default => $template,
  }

  $ensure = $bool_enable ? {
    false => 'absent',
    true  => 'present',
  }

  if ($tool =~ /monit/) {
    monit::checkpid { $name:
      pidfile      => $pidfile,
      process      => "${process}${argument}",
      startprogram => "/etc/init.d/${service} start",
      stopprogram  => "/etc/init.d/${service} stop",
      enable       => $bool_enable,
    }
  }

  if ($tool =~ /bluepill/) {
    bluepill::process { $name:
      pidfile      => $pidfile,
      process      => "${process}${argument}",
      startprogram => "/etc/init.d/${service} start",
      stopprogram  => "/etc/init.d/${service} stop",
      enable       => $bool_enable,
      config_hash  => $config_hash,
    }
  }

  if ($tool =~ /eye/) {
    eye::process { $name:
      pidfile      => $pidfile,
      process      => "${process}${argument}",
      startprogram => "/etc/init.d/${service} start",
      stopprogram  => "/etc/init.d/${service} stop",
      enable       => $bool_enable,
      config_hash  => $config_hash,
    }
  }

  $default_check_command = $argument ? {
    undef   => "check_nrpe!check_process!${process}",
    ''      => "check_nrpe!check_process!${process}",
    default => "check_nrpe!check_processwitharg!${process}!${argument}",
  }

  $check_command = $process ? {
    undef   => "check_nrpe!check_process!${name}",
    default => $default_check_command,
  }

  if ($tool =~ /nagios/) {
    nagios::service { $name:
      ensure              => $ensure,
      service_description => $service_description,
      template            => $real_template,
      check_command       => $check_command,
    }
  }

  if ($tool =~ /icinga/) {
    icinga::service { $name:
      ensure              => $ensure,
      service_description => $service_description,
      template            => $real_template,
      check_command       => $check_command,
    }
  }

  $puppi_default_command = $argument ? {
    undef   => "check_procs -c 1: -C ${process}",
    ''      => "check_procs -c 1: -C ${process}",
    default => "check_procs -c 1: -C ${process} -a ${argument}",
  }

  $puppi_command = $process ? {
    undef   => "check_procs -c 1: -C ${name}",
    default => $puppi_default_command,
  }

  if ($tool =~ /puppi/) {
    puppi::check { $name:
      enable   => $bool_enable,
      hostwide => 'yes',
      command  => $puppi_command,
    }
  }
}
