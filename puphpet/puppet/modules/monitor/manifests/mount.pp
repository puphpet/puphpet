# Define monitor::mount
#
# You can use this define to manage monitored mounts.
# It automatically monitors the mount point you specify
# AND IT MAY MOUNT it using Puppet's native mount define.
# So, generically, you just have to use monitor::mount
# instead of mount to manage your mount points.
# The possible arguments are the same of the native mount
# define plus some ones what define if and how to create the mount
# directory, if to just check the mount without managing it
# with Puppet and the tool(s) to use for monitoring.
# If you want to check the mount point only, without actually
# mounting it via the mount define, set only_check=true
#
define monitor::mount (
  $name,
  $device,
  $fstype,
  $options    = '',
  $pass       = '0',
  $remounts   = true,
  $ensure     = 'mounted',
  $atboot     = true,
  $only_check = false,
  $create_dir = false,
  $owner      = 'root',
  $group      = 'root',
  $mode       = '0755',
  $template   = '',
  $enable     = true,
  $tool       = $::monitor_tool
  ) {

  $bool_enable=any2bool($enable)

  $computed_ensure = $bool_enable ? {
    false => 'absent',
    true  => 'present',
  }

  # Manage template
  $real_template = $template ? {
    ''      => undef,
    default => $template,
  }

  $escapedname=regsubst($name,'/','_','G')

  # The mount is actually done (if $only_check != true )
  if ( $only_check != true ) {
    mount { $name:
      ensure   => $ensure,
      name     => $name,
      device   => $device,
      fstype   => $fstype,
      options  => $options,
      pass     => $pass,
      remounts => $remounts,
      atboot   => true,
    }
  }

  if ( $create_dir == true ) and ( $only_check != true ) {
    file { $name:
      ensure => directory,
      path   => $name,
      owner  => $owner,
      group  => $group,
      mode   => $mode,
      before => Mount[$name],
    }
  }

  if ($tool =~ /nagios/) {
    nagios::service { "Mount_${escapedname}":
      ensure        => $computed_ensure,
      template      => $real_template,
      check_command => "check_nrpe!check_mount!${name}!${fstype}",
    }
  }

  if ($tool =~ /icinga/) {
    icinga::service { "Mount_${escapedname}":
      ensure        => $computed_ensure,
      template      => $real_template,
      check_command => "check_nrpe!check_mount!${name}!${fstype}",
    }
  }

  if ($tool =~ /puppi/) {
    puppi::check { "Mount_${escapedname}":
      enable   => $enable,
      hostwide => 'yes',
      command  => "check_mount -m ${name} -t ${fstype}" ,
    }
  }

}

