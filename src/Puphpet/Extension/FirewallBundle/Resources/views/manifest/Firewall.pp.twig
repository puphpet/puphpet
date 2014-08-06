if $firewall_values == undef { $firewall_values = hiera_hash('firewall', false) }
if $vm_values == undef { $vm_values = hiera_hash($::vm_target_key, false) }

include puphpet::params

Firewall {
  before  => Class['my_fw::post'],
  require => Class['my_fw::pre'],
}

class { ['my_fw::pre', 'my_fw::post']: }

class { 'firewall': }

class my_fw::pre {
  Firewall {
    require => undef,
  }

  # Default firewall rules
  firewall { '000 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }
}

class my_fw::post {
  firewall { '999 drop all':
    proto   => 'all',
    action  => 'drop',
    before  => undef,
  }
}

if is_hash($firewall_values['rules']) and count($firewall_values['rules']) > 0 {
  each( $firewall_values['rules'] ) |$key, $rule| {
    if ! defined(Firewall["${rule['priority']} ${rule['proto']}/${rule['port']}"]) {
      firewall { "${rule['priority']} ${rule['proto']}/${rule['port']}":
        port   => $rule['port'],
        proto  => $rule['proto'],
        action => $rule['action'],
      }
    }
  }
}

if has_key($vm_values, 'ssh') and has_key($vm_values['ssh'], 'port') {
  $vm_values_ssh_port = $vm_values['ssh']['port'] ? {
    ''      => 22,
    undef   => 22,
    0       => 22,
    default => $vm_values['ssh']['port']
  }

  if ! defined(Firewall["100 tcp/${vm_values_ssh_port}"]) {
    firewall { "100 tcp/${vm_values_ssh_port}":
      port   => $vm_values_ssh_port,
      proto  => tcp,
      action => 'accept',
      before => Class['my_fw::post']
    }
  }
}

if has_key($vm_values, 'vm')
  and has_key($vm_values['vm'], 'network')
  and has_key($vm_values['vm']['network'], 'forwarded_port')
{
  create_resources( iptables_port, $vm_values['vm']['network']['forwarded_port'] )
}

define iptables_port (
  $host,
  $guest,
) {
  if ! defined(Firewall["100 tcp/${guest}"]) {
    firewall { "100 tcp/${guest}":
      port   => $guest,
      proto  => tcp,
      action => 'accept',
    }
  }
}
