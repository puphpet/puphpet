if $firewall_values == undef { $firewall_values = hiera_hash('firewall', false) }
if $vm_values == undef { $vm_values = hiera_hash('vagrantfile', false) }

include puphpet::params

Firewall {
  before  => Class['puphpet::firewall::post'],
  require => Class['puphpet::firewall::pre'],
}

class { ['puphpet::firewall::pre', 'puphpet::firewall::post']: }

class { 'firewall': }

# All ports defined in `firewall` yaml section
each( $firewall_values['rules'] ) |$key, $rule| {
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
if has_key($vm_values, 'ssh')
  and has_key($vm_values['ssh'], 'port')
{
  $vm_values_ssh_port = $vm_values['ssh']['port'] ? {
    ''      => 22,
    undef   => 22,
    0       => 22,
    default => $vm_values['ssh']['port']
  }

  if ! defined(Puphpet::Firewall::Port[$vm_values_ssh_port]) {
    puphpet::firewall::port { $vm_values_ssh_port: }
  }
}

# Opens up forwarded ports; remote servers won't have these keys
if has_key($vm_values, 'vm')
  and has_key($vm_values['vm'], 'network')
  and has_key($vm_values['vm']['network'], 'forwarded_port')
{
  each( $vm_values['vm']['network']['forwarded_port'] ) |$key, $ports| {
    if ! defined(Puphpet::Firewall::Port[$ports['guest']]) {
      puphpet::firewall::port { $ports['guest']: }
    }
  }
}
