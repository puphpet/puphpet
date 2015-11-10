class puphpet_firewall (
  $firewall,
  $vm
) {

  Firewall {
    before  => Class['puphpet::firewall::post'],
    require => Class['puphpet::firewall::pre'],
  }

  class { ['puphpet::firewall::pre', 'puphpet::firewall::post', 'firewall']: }

  each( $firewall['rules'] ) |$key, $rule| {
    if is_string($rule['port']) {
      $ports = [$rule['port']]
    } else {
      $ports = $rule['port']
    }

    each( $ports ) |$port| {
      if ! defined(Puphpet::Firewall::Port[$port]) {
        if has_key($rule, 'priority') {
          $priority = $rule['priority']
        } else {
          $priority = 100
        }

        puphpet::firewall::port { $port:
          protocol => $rule['proto'],
          priority => $priority,
          action   => $rule['action'],
        }
      }
    }
  }

  # Opens up SSH port defined in `vagrantfile-*` section
  if has_key($vm, 'ssh') and has_key($vm['ssh'], 'port') {
    $vm_ssh_port = $vm['ssh']['port'] ? {
      ''      => 22,
      undef   => 22,
      0       => 22,
      default => $vm['ssh']['port']
    }

    if ! defined(Puphpet::Firewall::Port[$vm_ssh_port]) {
      puphpet::firewall::port { $vm_ssh_port: }
    }
  }

  # Opens up forwarded ports; remote servers won't have these keys
  if has_key($vm, 'vm')
    and has_key($vm['vm'], 'network')
    and has_key($vm['vm']['network'], 'forwarded_port')
  {
    each( $vm['vm']['network']['forwarded_port'] ) |$key, $ports| {
      if ! defined(Puphpet::Firewall::Port[$ports['guest']]) {
        puphpet::firewall::port { $ports['guest']: }
      }
    }
  }

}
