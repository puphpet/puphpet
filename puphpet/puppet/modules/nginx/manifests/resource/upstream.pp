# define: nginx::resource::upstream
#
# This definition creates a new upstream proxy entry for NGINX
#
# Parameters:
#   [*members*]               - Array of member URIs for NGINX to connect to. Must follow valid NGINX syntax.
#                               If omitted, individual members should be defined with nginx::resource::upstream::member
#   [*ensure*]                - Enables or disables the specified location (present|absent)
#   [*upstream_cfg_prepend*]  - It expects a hash with custom directives to put before anything else inside upstream
#   [*upstream_fail_timeout*] - Set the fail_timeout for the upstream. Default is 10 seconds - As that is what Nginx does normally.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  nginx::resource::upstream { 'proxypass':
#    ensure  => present,
#    members => [
#      'localhost:3000',
#      'localhost:3001',
#      'localhost:3002',
#    ],
#  }
#
#  Custom config example to use ip_hash, and 20 keepalive connections
#  create a hash with any extra custom config you want.
#  $my_config = {
#    'ip_hash'   => '',
#    'keepalive' => '20',
#  }
#  nginx::resource::upstream { 'proxypass':
#    ensure              => present,
#    members => [
#      'localhost:3000',
#      'localhost:3001',
#      'localhost:3002',
#    ],
#    upstream_cfg_prepend => $my_config,
#  }
define nginx::resource::upstream (
  $members = undef,
  $ensure = 'present',
  $upstream_cfg_prepend = undef,
  $upstream_fail_timeout = '10s',
) {

  if $members != undef {
    validate_array($members)
  }
  validate_re($ensure, '^(present|absent)$',
    "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")
  if ($upstream_cfg_prepend != undef) {
    validate_hash($upstream_cfg_prepend)
  }

  include nginx::params
  $root_group = $nginx::params::root_group

  Concat {
    owner => 'root',
    group => $root_group,
    mode  => '0644',
  }

  concat { "${nginx::config::conf_dir}/conf.d/${name}-upstream.conf":
    ensure  => $ensure ? {
      'absent' => absent,
      'file'   => present,
      default  => present,
    },
    notify  => Class['nginx::service'],
  }

  # Uses: $name, $upstream_cfg_prepend
  concat::fragment { "${name}_upstream_header":
    target  => "${nginx::config::conf_dir}/conf.d/${name}-upstream.conf",
    order   => 10,
    content => template('nginx/conf.d/upstream_header.erb'),
  }

  if $members != undef {
    # Uses: $members, $upstream_fail_timeout
    concat::fragment { "${name}_upstream_members":
      target  => "${nginx::config::conf_dir}/conf.d/${name}-upstream.conf",
      order   => 50,
      content => template('nginx/conf.d/upstream_members.erb'),
    }
  } else {
    # Collect exported members:
    Nginx::Resource::Upstream::Member <<| upstream == $name |>>
  }

  concat::fragment { "${name}_upstream_footer":
    target  => "${nginx::config::conf_dir}/conf.d/${name}-upstream.conf",
    order   => 90,
    content => "}\n",
  }
}
