# Main rabbitmq class
class rabbitmq(
  $admin_enable               = $rabbitmq::params::admin_enable,
  $cluster_node_type          = $rabbitmq::params::cluster_node_type,
  $cluster_nodes              = $rabbitmq::params::cluster_nodes,
  $config                     = $rabbitmq::params::config,
  $config_cluster             = $rabbitmq::params::config_cluster,
  $config_path                = $rabbitmq::params::config_path,
  $config_stomp               = $rabbitmq::params::config_stomp,
  $default_user               = $rabbitmq::params::default_user,
  $default_pass               = $rabbitmq::params::default_pass,
  $delete_guest_user          = $rabbitmq::params::delete_guest_user,
  $env_config                 = $rabbitmq::params::env_config,
  $env_config_path            = $rabbitmq::params::env_config_path,
  $erlang_cookie              = $rabbitmq::params::erlang_cookie,
  $interface                  = $rabbitmq::params::interface,
  $management_port            = $rabbitmq::params::management_port,
  $node_ip_address            = $rabbitmq::params::node_ip_address,
  $package_apt_pin            = $rabbitmq::params::package_apt_pin,
  $package_ensure             = $rabbitmq::params::package_ensure,
  $package_gpg_key            = $rabbitmq::params::package_gpg_key,
  $package_name               = $rabbitmq::params::package_name,
  $package_provider           = $rabbitmq::params::package_provider,
  $package_source             = undef,
  $repos_ensure               = $rabbitmq::params::repos_ensure,
  $manage_repos               = $rabbitmq::params::manage_repos,
  $plugin_dir                 = $rabbitmq::params::plugin_dir,
  $rabbitmq_user              = $rabbitmq::params::rabbitmq_user,
  $rabbitmq_group             = $rabbitmq::params::rabbitmq_group,
  $rabbitmq_home              = $rabbitmq::params::rabbitmq_home,
  $port                       = $rabbitmq::params::port,
  $tcp_keepalive              = $rabbitmq::params::tcp_keepalive,
  $service_ensure             = $rabbitmq::params::service_ensure,
  $service_manage             = $rabbitmq::params::service_manage,
  $service_name               = $rabbitmq::params::service_name,
  $ssl                        = $rabbitmq::params::ssl,
  $ssl_only                   = $rabbitmq::params::ssl_only,
  $ssl_cacert                 = $rabbitmq::params::ssl_cacert,
  $ssl_cert                   = $rabbitmq::params::ssl_cert,
  $ssl_key                    = $rabbitmq::params::ssl_key,
  $ssl_port                   = $rabbitmq::params::ssl_port,
  $ssl_interface              = $rabbitmq::params::ssl_interface,
  $ssl_management_port        = $rabbitmq::params::ssl_management_port,
  $ssl_stomp_port             = $rabbitmq::params::ssl_stomp_port,
  $ssl_verify                 = $rabbitmq::params::ssl_verify,
  $ssl_fail_if_no_peer_cert   = $rabbitmq::params::ssl_fail_if_no_peer_cert,
  $ssl_versions               = $rabbitmq::params::ssl_versions,
  $ssl_ciphers                = $rabbitmq::params::ssl_ciphers,
  $stomp_ensure               = $rabbitmq::params::stomp_ensure,
  $ldap_auth                  = $rabbitmq::params::ldap_auth,
  $ldap_server                = $rabbitmq::params::ldap_server,
  $ldap_user_dn_pattern       = $rabbitmq::params::ldap_user_dn_pattern,
  $ldap_other_bind            = $rabbitmq::params::ldap_other_bind,
  $ldap_use_ssl               = $rabbitmq::params::ldap_use_ssl,
  $ldap_port                  = $rabbitmq::params::ldap_port,
  $ldap_log                   = $rabbitmq::params::ldap_log,
  $ldap_config_variables      = $rabbitmq::params::ldap_config_variables,
  $stomp_port                 = $rabbitmq::params::stomp_port,
  $version                    = $rabbitmq::params::version,
  $wipe_db_on_cookie_change   = $rabbitmq::params::wipe_db_on_cookie_change,
  $cluster_partition_handling = $rabbitmq::params::cluster_partition_handling,
  $file_limit                 = $rabbitmq::params::file_limit,
  $environment_variables      = $rabbitmq::params::environment_variables,
  $config_variables           = $rabbitmq::params::config_variables,
  $config_kernel_variables    = $rabbitmq::params::config_kernel_variables,
  $key_content                = undef,
) inherits rabbitmq::params {

  validate_bool($admin_enable)
  # Validate install parameters.
  validate_re($package_apt_pin, '^(|\d+)$')
  validate_string($package_ensure)
  validate_string($package_gpg_key)
  validate_string($package_name)
  validate_string($package_provider)
  validate_bool($repos_ensure)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') # Allow 3 digits and optional -n postfix.
  # Validate config parameters.
  validate_re($cluster_node_type, '^(ram|disc|disk)$') # Both disc and disk are valid http://www.rabbitmq.com/clustering.html
  validate_array($cluster_nodes)
  validate_string($config)
  validate_absolute_path($config_path)
  validate_bool($config_cluster)
  validate_bool($config_stomp)
  validate_string($default_user)
  validate_string($default_pass)
  validate_bool($delete_guest_user)
  validate_string($env_config)
  validate_absolute_path($env_config_path)
  validate_string($erlang_cookie)
  if ! is_integer($management_port) {
    validate_re($management_port, '\d+')
  }
  validate_string($node_ip_address)
  validate_absolute_path($plugin_dir)
  if ! is_integer($port) {
    validate_re($port, ['\d+','UNSET'])
  }
  if ! is_integer($stomp_port) {
    validate_re($stomp_port, '\d+')
  }
  validate_bool($wipe_db_on_cookie_change)
  validate_bool($tcp_keepalive)
  if ! is_integer($file_limit) {
    validate_re($file_limit, '^(unlimited|infinity)$', '$file_limit must be an integer, \'unlimited\', or \'infinity\'.')
  }
  # Validate service parameters.
  validate_re($service_ensure, '^(running|stopped)$')
  validate_bool($service_manage)
  validate_string($service_name)
  validate_bool($ssl)
  validate_bool($ssl_only)
  validate_string($ssl_cacert)
  validate_string($ssl_cert)
  validate_string($ssl_key)
  validate_array($ssl_ciphers)
  if ! is_integer($ssl_port) {
    validate_re($ssl_port, '\d+')
  }
  if ! is_integer($ssl_management_port) {
    validate_re($ssl_management_port, '\d+')
  }
  if ! is_integer($ssl_stomp_port) {
    validate_re($ssl_stomp_port, '\d+')
  }
  validate_bool($stomp_ensure)
  validate_bool($ldap_auth)
  validate_string($ldap_server)
  validate_string($ldap_user_dn_pattern)
  validate_string($ldap_other_bind)
  validate_hash($ldap_config_variables)
  validate_bool($ldap_use_ssl)
  validate_re($ldap_port, '\d+')
  validate_bool($ldap_log)
  validate_hash($environment_variables)
  validate_hash($config_variables)
  validate_hash($config_kernel_variables)

  if $ssl_only and ! $ssl {
    fail('$ssl_only => true requires that $ssl => true')
  }

  if $config_stomp and $ssl_stomp_port and ! $ssl {
    warning('$ssl_stomp_port requires that $ssl => true and will be ignored')
  }

  if $ssl_versions {
    if $ssl {
      validate_array($ssl_versions)
    } else {
      fail('$ssl_versions requires that $ssl => true')
    }
  }

  # This needs to happen here instead of params.pp because
  # $package_source needs to override the constructed value in params.pp
  if $package_source { # $package_source was specified by user so use that one
    $real_package_source = $package_source
  # NOTE(bogdando) do not enforce the source value for yum provider #MODULES-1631
  } elsif $package_provider != 'yum' {
    # package_source was not specified, so construct it, unless the provider is 'yum'
    case $::osfamily {
      'RedHat', 'SUSE': {
        $base_version   = regsubst($version,'^(.*)-\d$','\1')
        $real_package_source = "http://www.rabbitmq.com/releases/rabbitmq-server/v${base_version}/rabbitmq-server-${version}.noarch.rpm"
      }
      default: { # Archlinux and Debian
        $real_package_source = ''
      }
    }
  } else { # for yum provider, use the source as is
    $real_package_source = $package_source
  }

  include '::rabbitmq::install'
  include '::rabbitmq::config'
  include '::rabbitmq::service'
  include '::rabbitmq::management'

  if $manage_repos != undef {
    warning('$manage_repos is now deprecated. Please use $repos_ensure instead')
  }

  if $manage_repos != false {
    case $::osfamily {
      'RedHat', 'SUSE':
        { include '::rabbitmq::repo::rhel' }
      'Debian': {
        class { '::rabbitmq::repo::apt' :
          key_source  => $package_gpg_key,
          key_content => $key_content,
        }
      }
      default:
        { }
    }
  }

  if $admin_enable and $service_manage {
    include '::rabbitmq::install::rabbitmqadmin'

    rabbitmq_plugin { 'rabbitmq_management':
      ensure  => present,
      require => Class['rabbitmq::install'],
      notify  => Class['rabbitmq::service'],
    }

    Class['::rabbitmq::service'] -> Class['::rabbitmq::install::rabbitmqadmin']
    Class['::rabbitmq::install::rabbitmqadmin'] -> Rabbitmq_exchange<| |>
  }

  if $stomp_ensure {
    rabbitmq_plugin { 'rabbitmq_stomp':
      ensure  => present,
      require => Class['rabbitmq::install'],
      notify  => Class['rabbitmq::service'],
    }
  }

  if ($ldap_auth) {
    rabbitmq_plugin { 'rabbitmq_auth_backend_ldap':
      ensure  => present,
      require => Class['rabbitmq::install'],
      notify  => Class['rabbitmq::service'],
    }
  }

  anchor { 'rabbitmq::begin': }
  anchor { 'rabbitmq::end': }

  Anchor['rabbitmq::begin'] -> Class['::rabbitmq::install']
    -> Class['::rabbitmq::config'] ~> Class['::rabbitmq::service']
    -> Class['::rabbitmq::management'] -> Anchor['rabbitmq::end']

  # Make sure the various providers have their requirements in place.
  Class['::rabbitmq::install'] -> Rabbitmq_plugin<| |>

}
