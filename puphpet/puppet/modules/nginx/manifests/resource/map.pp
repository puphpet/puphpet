# define: nginx::resource::map
#
# This definition creates a new mapping entry for NGINX
#
# Parameters:
#   [*ensure*]     - Enables or disables the specified location (present|absent)
#   [*default*]    - Sets the resulting value if the source values fails to
#                    match any of the variants.
#   [*string*]     - Source string or variable to provide mapping for
#   [*mappings*]   - Hash of map lookup keys and resultant values
#   [*hostnames*]  - Indicates that source values can be hostnames with a
#                    prefix or suffix mask.

# Actions:
#
# Requires:
#
# Sample Usage:
#
#  nginx::resource::map { 'backend_pool':
#    ensure    => present,
#    hostnames => true,
#    default   => 'ny-pool-1,
#    string    => '$http_host',
#    mappings  => {
#      '*.nyc.example.com' => 'ny-pool-1',
#      '*.sf.example.com'  => 'sf-pool-1',
#    }
#  }
#
# Sample Hiera usage:
#
#  nginx::maps:
#    client_network:
#      ensure: present
#      hostnames: true
#      default: 'ny-pool-1'
#      string: $http_host
#      mappings:
#        '*.nyc.example.com': 'ny-pool-1'
#        '*.sf.example.com': 'sf-pool-1'


define nginx::resource::map (
  $string,
  $mappings,
  $default    = undef,
  $ensure     = 'present',
  $hostnames  = false
) {
  validate_string($string)
  validate_re($string, '^.{2,}$',
    "Invalid string value [${string}]. Expected a minimum of 2 characters.")
  validate_hash($mappings)
  validate_bool($hostnames)
  validate_re($ensure, '^(present|absent)$',
    "Invalid ensure value '${ensure}'. Expected 'present' or 'absent'")
  if ($default != undef) { validate_string($default) }

  include nginx::params
  $root_group = $nginx::params::root_group

  File {
    owner => 'root',
    group => $root_group,
    mode  => '0644',
  }

  file { "${nginx::config::conf_dir}/conf.d/${name}-map.conf":
    ensure  => $ensure ? {
      'absent' => absent,
      default  => 'file',
    },
    content => template('nginx/conf.d/map.erb'),
    notify  => Class['nginx::service'],
  }
}
