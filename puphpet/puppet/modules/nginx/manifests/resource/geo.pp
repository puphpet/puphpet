# define: nginx::resource::geo
#
# This definition creates a new geo mapping entry for NGINX
#
# Parameters:
#   [*networks*]        - Hash of geo lookup keys and resultant values
#   [*default*]         - Sets the resulting value if the source value fails to
#                         match any of the variants.
#   [*ensure*]          - Enables or disables the specified location
#   [*ranges*]          - Indicates that lookup keys (network addresses) are
#                         specified as ranges.
#   [*address*]         - Nginx defaults to using $remote_addr for testing.
#                         This allows you to override that with another variable
#                         name (automatically prefixed with $)
#   [*delete*]          - deletes the specified network (see: geo module docs)
#   [*proxy_recursive*] - Changes the behavior of address acquisition when
#                         specifying trusted proxies via 'proxies' directive
#   [*proxies*]         - Hash of network->value mappings.

# Actions:
#
# Requires:
#
# Sample Usage:
#
#  nginx::resource::geo { 'client_network':
#    ensure          => present,
#    ranges          => false,
#    default         => extra,
#    proxy_recursive => false,
#    proxies         => [ '192.168.99.99' ],
#    networks        => {
#      '10.0.0.0/8'     => 'intra',
#      '172.16.0.0/12'  => 'intra',
#      '192.168.0.0/16' => 'intra',
#    }
#  }
#
# Sample Hiera usage:
#
#  nginx::geos:
#    client_network:
#      ensure: present
#      ranges: false
#      default: 'extra'
#      proxy_recursive: false
#      proxies:
#         - 192.168.99.99
#      networks:
#        '10.0.0.0/8': 'intra'
#        '172.16.0.0/12': 'intra'
#        '192.168.0.0/16': 'intra'


define nginx::resource::geo (
  $networks,
  $default         = undef,
  $ensure          = 'present',
  $ranges          = false,
  $address         = undef,
  $delete          = undef,
  $proxies         = undef,
  $proxy_recursive = undef
) {

  validate_hash($networks)
  validate_bool($ranges)
  validate_re($ensure, '^(present|absent)$',
    "Invalid ensure value '${ensure}'. Expected 'present' or 'absent'")
  if ($default != undef) { validate_string($default) }
  if ($address != undef) { validate_string($address) }
  if ($delete != undef) { validate_string($delete) }
  if ($proxies != undef) { validate_array($proxies) }
  if ($proxy_recursive != undef) { validate_bool($proxy_recursive) }

  include nginx::params
  $root_group = $nginx::params::root_group

  File {
    owner => 'root',
    group => $root_group,
    mode  => '0644',
  }

  file { "${nginx::config::conf_dir}/conf.d/${name}-geo.conf":
    ensure  => $ensure ? {
      'absent' => absent,
      default  => 'file',
    },
    content => template('nginx/conf.d/geo.erb'),
    notify  => Class['nginx::service'],
  }
}
