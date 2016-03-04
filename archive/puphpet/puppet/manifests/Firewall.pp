class puphpet_firewall (
  $firewall,
  $vm
) {

  Firewall {
    before  => Class['puphpet::firewall::post'],
    require => Class['puphpet::firewall::pre'],
  }

  class { ['puphpet::firewall::pre', 'puphpet::firewall::post', 'firewall']: }

  # config file could contain no rules key
  $rules = array_true($firewall, 'rules') ? {
    true    => $firewall['rules'],
    default => { }
  }

  each( $rules ) |$key, $rule| {
    if is_string($rule['port']) {
      $ports = [$rule['port']]
    } else {
      $ports = $rule['port']
    }

    each( $ports ) |$port| {
      if ! defined(Puphpet::Firewall::Port["${port}"]) {
        if has_key($rule, 'priority') {
          $priority = $rule['priority']
        } else {
          $priority = 100
        }

        puphpet::firewall::port { "${port}":
          protocol => $rule['proto'],
          priority => $priority,
          action   => $rule['action'],
        }
      }
    }
  }

  # Opens up SSH port defined in `vagrantfile-*` section
  if has_key($vm, 'ssh') and has_key($vm['ssh'], 'port') {
    $vm_ssh_port = array_true($vm['ssh'], 'port') ? {
      true  => $vm['ssh']['port'],
      false => 22,
    }
  } else {
    $vm_ssh_port = 22
  }

  if ! defined(Puphpet::Firewall::Port["${vm_ssh_port}"]) {
    puphpet::firewall::port { "${vm_ssh_port}": }
  }

  # Opens up forwarded ports on locale machines; remote servers won't have these keys
  if array_true($vm['vm']['provider'], 'local') {
    each( $vm['vm']['provider']['local']['machines'] ) |$mId, $machine| {
      # config file could contain no forwarded ports
      $forwarded_ports = array_true($machine['network'], 'forwarded_port') ? {
        true    => $machine['network']['forwarded_port'],
        default => { }
      }

      each( $forwarded_ports ) |$pId, $port| {
        if ! defined(Puphpet::Firewall::Port["${port['guest']}"]) {
          puphpet::firewall::port { "${port['guest']}": }
        }
      }
    }
  }

}
