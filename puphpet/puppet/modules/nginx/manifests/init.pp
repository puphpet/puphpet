# Class: nginx
#
# This module manages NGINX.
#
# Parameters:
#
# There are no default parameters for this class. All module parameters
# are managed via the nginx::params class
#
# Actions:
#
# Requires:
#  puppetlabs-stdlib - https://github.com/puppetlabs/puppetlabs-stdlib
#
#  Packaged NGINX
#    - RHEL: EPEL or custom package
#    - Debian/Ubuntu: Default Install or custom package
#    - SuSE: Default Install or custom package
#
#  stdlib
#    - puppetlabs-stdlib module >= 0.1.6
#    - plugin sync enabled to obtain the anchor type
#
# Sample Usage:
#
# The module works with sensible defaults:
#
# node default {
#   include nginx
# }
class nginx (
  $client_body_buffer_size        = $nginx::params::nx_client_body_buffer_size,
  $client_body_temp_path          = $nginx::params::nx_client_body_temp_path,
  $client_max_body_size           = $nginx::params::nx_client_max_body_size,
  $confd_purge                    = $nginx::params::nx_confd_purge,
  $configtest_enable              = $nginx::params::nx_configtest_enable,
  $conf_dir                       = $nginx::params::nx_conf_dir,
  $conf_template                  = $nginx::params::nx_conf_template,
  $daemon_user                    = $nginx::params::nx_daemon_user,
  $events_use                     = $nginx::params::nx_events_use,
  $fastcgi_cache_inactive         = $nginx::params::nx_fastcgi_cache_inactive,
  $fastcgi_cache_key              = $nginx::params::nx_fastcgi_cache_key,
  $fastcgi_cache_keys_zone        = $nginx::params::nx_fastcgi_cache_keys_zone,
  $fastcgi_cache_levels           = $nginx::params::nx_fastcgi_cache_levels,
  $fastcgi_cache_max_size         = $nginx::params::nx_fastcgi_cache_max_size,
  $fastcgi_cache_path             = $nginx::params::nx_fastcgi_cache_path,
  $fastcgi_cache_use_stale        = $nginx::params::nx_fastcgi_cache_use_stale,
  $gzip                           = $nginx::params::nx_gzip,
  $http_access_log                = $nginx::params::nx_http_access_log,
  $http_cfg_append                = $nginx::params::nx_http_cfg_append,
  $http_tcp_nodelay               = $nginx::params::nx_http_tcp_nodelay,
  $http_tcp_nopush                = $nginx::params::nx_http_tcp_nopush,
  $keepalive_timeout              = $nginx::params::nx_keepalive_timeout,
  $logdir                         = $nginx::params::nx_logdir,
  $mail                           = $nginx::params::nx_mail,
  $manage_repo                    = $nginx::params::manage_repo,
  $multi_accept                   = $nginx::params::nx_multi_accept,
  $names_hash_bucket_size         = $nginx::params::nx_names_hash_bucket_size,
  $names_hash_max_size            = $nginx::params::nx_names_hash_max_size,
  $nginx_error_log                = $nginx::params::nx_nginx_error_log,
  $nginx_locations                = {},
  $nginx_mailhosts                = {},
  $nginx_upstreams                = {},
  $nginx_vhosts                   = {},
  $package_ensure                 = $nginx::params::package_ensure,
  $package_name                   = $nginx::params::package_name,
  $package_source                 = $nginx::params::package_source,
  $pid                            = $nginx::params::nx_pid,
  $proxy_buffers                  = $nginx::params::nx_proxy_buffers,
  $proxy_buffer_size              = $nginx::params::nx_proxy_buffer_size,
  $proxy_cache_inactive           = $nginx::params::nx_proxy_cache_inactive,
  $proxy_cache_keys_zone          = $nginx::params::nx_proxy_cache_keys_zone,
  $proxy_cache_levels             = $nginx::params::nx_proxy_cache_levels,
  $proxy_cache_max_size           = $nginx::params::nx_proxy_cache_max_size,
  $proxy_cache_path               = $nginx::params::nx_proxy_cache_path,
  $proxy_conf_template            = $nginx::params::nx_proxy_conf_template,
  $proxy_connect_timeout          = $nginx::params::nx_proxy_connect_timeout,
  $proxy_headers_hash_bucket_size = $nginx::params::nx_proxy_headers_hash_bucket_size,
  $proxy_http_version             = $nginx::params::nx_proxy_http_version,
  $proxy_read_timeout             = $nginx::params::nx_proxy_read_timeout,
  $proxy_redirect                 = $nginx::params::nx_proxy_redirect,
  $proxy_send_timeout             = $nginx::params::nx_proxy_send_timeout,
  $proxy_set_header               = $nginx::params::nx_proxy_set_header,
  $proxy_temp_path                = $nginx::params::nx_proxy_temp_path,
  $run_dir                        = $nginx::params::nx_run_dir,
  $sendfile                       = $nginx::params::nx_sendfile,
  $server_tokens                  = $nginx::params::nx_server_tokens,
  $service_ensure                 = $nginx::params::nx_service_ensure,
  $service_restart                = $nginx::params::nx_service_restart,
  $spdy                           = $nginx::params::nx_spdy,
  $super_user                     = $nginx::params::nx_super_user,
  $temp_dir                       = $nginx::params::nx_temp_dir,
  $types_hash_bucket_size         = $nginx::params::nx_types_hash_bucket_size,
  $types_hash_max_size            = $nginx::params::nx_types_hash_max_size,
  $vhost_purge                    = $nginx::params::nx_vhost_purge,
  $worker_connections             = $nginx::params::nx_worker_connections,
  $worker_processes               = $nginx::params::nx_worker_processes,
  $worker_rlimit_nofile           = $nginx::params::nx_worker_rlimit_nofile,
  $global_owner                   = $nginx::params::nx_global_owner,
  $global_group                   = $nginx::params::nx_global_group,
  $global_mode                    = $nginx::params::nx_global_mode,
  $sites_available_owner          = $nginx::params::nx_sites_available_owner,
  $sites_available_group          = $nginx::params::nx_sites_available_group,
  $sites_available_mode           = $nginx::params::nx_sites_available_mode,
  $geo_mappings                   = {},
  $string_mappings                = {},
) inherits nginx::params {

  include stdlib

  if (!is_string($worker_processes)) and (!is_integer($worker_processes)) {
    fail('$worker_processes must be an integer or have value "auto".')
  }
  if (!is_integer($worker_connections)) {
    fail('$worker_connections must be an integer.')
  }
  if (!is_integer($worker_rlimit_nofile)) {
    fail('$worker_rlimit_nofile must be an integer.')
  }
  if (!is_string($events_use)) and ($events_use != false) {
    fail('$events_use must be a string or false.')
  }
  validate_string($multi_accept)
  validate_string($package_name)
  validate_string($package_ensure)
  validate_string($package_source)
  validate_array($proxy_set_header)
  validate_string($proxy_http_version)
  validate_bool($confd_purge)
  validate_bool($vhost_purge)
  if ($proxy_cache_path != false) {
    validate_string($proxy_cache_path)
  }
  if (!is_integer($proxy_cache_levels)) {
    fail('$proxy_cache_levels must be an integer.')
  }
  validate_string($proxy_cache_keys_zone)
  validate_string($proxy_cache_max_size)
  validate_string($proxy_cache_inactive)

  if ($fastcgi_cache_path != false) {
        validate_string($fastcgi_cache_path)
  }
  if (!is_integer($fastcgi_cache_levels)) {
    fail('$fastcgi_cache_levels must be an integer.')
  }
  validate_string($fastcgi_cache_keys_zone)
  validate_string($fastcgi_cache_max_size)
  validate_string($fastcgi_cache_inactive)
  if ($fastcgi_cache_key != false) {
    validate_string($fastcgi_cache_key)
  }
  if ($fastcgi_cache_use_stale != false) {
    validate_string($fastcgi_cache_use_stale)
  }

  validate_bool($configtest_enable)
  validate_string($service_restart)
  validate_bool($mail)
  validate_string($server_tokens)
  validate_string($client_max_body_size)
  if (!is_integer($names_hash_bucket_size)) {
    fail('$names_hash_bucket_size must be an integer.')
  }
  if (!is_integer($names_hash_max_size)) {
    fail('$names_hash_max_size must be an integer.')
  }
  validate_string($proxy_buffers)
  validate_string($proxy_buffer_size)
  if ($http_cfg_append != false) {
    if !(is_hash($http_cfg_append) or is_array($http_cfg_append)) {
      fail('$http_cfg_append must be either a hash or array')
    }
  }

  validate_string($nginx_error_log)
  validate_string($http_access_log)
  validate_hash($nginx_upstreams)
  validate_hash($nginx_vhosts)
  validate_hash($nginx_locations)
  validate_hash($nginx_mailhosts)
  validate_bool($manage_repo)
  validate_string($proxy_headers_hash_bucket_size)
  validate_bool($super_user)

  validate_hash($string_mappings)
  validate_hash($geo_mappings)

  class { 'nginx::package':
    package_name   => $package_name,
    package_source => $package_source,
    package_ensure => $package_ensure,
    notify         => Class['nginx::service'],
    manage_repo    => $manage_repo,
  }

  class { 'nginx::config':
    client_body_buffer_size        => $client_body_buffer_size,
    client_body_temp_path          => $client_body_temp_path,
    client_max_body_size           => $client_max_body_size,
    confd_purge                    => $confd_purge,
    conf_dir                       => $conf_dir,
    conf_template                  => $conf_template,
    daemon_user                    => $daemon_user,
    events_use                     => $events_use,
    fastcgi_cache_inactive         => $fastcgi_cache_inactive,
    fastcgi_cache_key              => $fastcgi_cache_key,
    fastcgi_cache_keys_zone        => $fastcgi_cache_keys_zone,
    fastcgi_cache_levels           => $fastcgi_cache_levels,
    fastcgi_cache_max_size         => $fastcgi_cache_max_size,
    fastcgi_cache_path             => $fastcgi_cache_path,
    fastcgi_cache_use_stale        => $fastcgi_cache_use_stale,
    gzip                           => $gzip,
    http_access_log                => $http_access_log,
    http_cfg_append                => $http_cfg_append,
    http_tcp_nodelay               => $http_tcp_nodelay,
    http_tcp_nopush                => $http_tcp_nopush,
    keepalive_timeout              => $keepalive_timeout,
    logdir                         => $logdir,
    mail                           => $mail,
    multi_accept                   => $multi_accept,
    names_hash_bucket_size         => $names_hash_bucket_size,
    names_hash_max_size            => $names_hash_max_size,
    nginx_error_log                => $nginx_error_log,
    pid                            => $pid,
    proxy_buffers                  => $proxy_buffers,
    proxy_buffer_size              => $proxy_buffer_size,
    proxy_cache_inactive           => $proxy_cache_inactive,
    proxy_cache_keys_zone          => $proxy_cache_keys_zone,
    proxy_cache_levels             => $proxy_cache_levels,
    proxy_cache_max_size           => $proxy_cache_max_size,
    proxy_cache_path               => $proxy_cache_path,
    proxy_conf_template            => $proxy_conf_template,
    proxy_connect_timeout          => $proxy_connect_timeout,
    proxy_headers_hash_bucket_size => $proxy_headers_hash_bucket_size,
    proxy_http_version             => $proxy_http_version,
    proxy_read_timeout             => $proxy_read_timeout,
    proxy_redirect                 => $proxy_redirect,
    proxy_send_timeout             => $proxy_send_timeout,
    proxy_set_header               => $proxy_set_header,
    proxy_temp_path                => $proxy_temp_path,
    run_dir                        => $run_dir,
    sendfile                       => $sendfile,
    server_tokens                  => $server_tokens,
    spdy                           => $spdy,
    super_user                     => $super_user,
    temp_dir                       => $temp_dir,
    types_hash_bucket_size         => $types_hash_bucket_size,
    types_hash_max_size            => $types_hash_max_size,
    vhost_purge                    => $vhost_purge,
    worker_connections             => $worker_connections,
    worker_processes               => $worker_processes,
    worker_rlimit_nofile           => $worker_rlimit_nofile,
    global_owner                   => $global_owner,
    global_group                   => $global_group,
    global_mode                    => $global_mode,
    sites_available_owner          => $sites_available_owner,
    sites_available_group          => $sites_available_group,
    sites_available_mode           => $sites_available_mode,
    require                        => Class['nginx::package'],
    notify                         => Class['nginx::service'],
  }

  class { 'nginx::service':
  }

  create_resources('nginx::resource::upstream', $nginx_upstreams)
  create_resources('nginx::resource::vhost', $nginx_vhosts)
  create_resources('nginx::resource::location', $nginx_locations)
  create_resources('nginx::resource::mailhost', $nginx_mailhosts)
  create_resources('nginx::resource::map', $string_mappings)
  create_resources('nginx::resource::geo', $geo_mappings)

  # Allow the end user to establish relationships to the "main" class
  # and preserve the relationship to the implementation classes through
  # a transitive relationship to the composite class.
  anchor{ 'nginx::begin':
    before => Class['nginx::package'],
    notify => Class['nginx::service'],
  }
  anchor { 'nginx::end':
    require => Class['nginx::service'],
  }
}
