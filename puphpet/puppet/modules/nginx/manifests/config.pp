# Class: nginx::config
#
# This module manages NGINX bootstrap and configuration
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class nginx::config(
  $client_body_buffer_size        = $nginx::params::nx_client_body_buffer_size,
  $client_body_temp_path          = $nginx::params::nx_client_body_temp_path,
  $client_max_body_size           = $nginx::params::nx_client_max_body_size,
  $confd_purge                    = $nginx::params::nx_confd_purge,
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
  $multi_accept                   = $nginx::params::nx_multi_accept,
  $names_hash_bucket_size         = $nginx::params::nx_names_hash_bucket_size,
  $names_hash_max_size            = $nginx::params::nx_names_hash_max_size,
  $nginx_error_log                = $nginx::params::nx_nginx_error_log,
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
  $spdy                           = $nginx::params::nx_spdy,
  $super_user                     = $nginx::params::nx_super_user,
  $temp_dir                       = $nginx::params::nx_temp_dir,
  $types_hash_bucket_size         = $nginx::params::nx_types_hash_bucket_size,
  $types_hash_max_size            = $nginx::params::nx_types_hash_max_size,
  $vhost_purge                    = $nginx::params::nx_vhost_purge,
  $worker_connections             = $nginx::params::nx_worker_connections,
  $worker_processes               = $nginx::params::nx_worker_processes,
  $worker_rlimit_nofile           = $nginx::params::nx_worker_rlimit_nofile,
  $global_owner                   = $nginx::params::global_owner,
  $global_group                   = $nginx::params::global_group,
  $global_mode                    = $nginx::params::global_mode,
  $sites_available_owner          = $nginx::params::sites_available_owner,
  $sites_available_group          = $nginx::params::sites_available_group,
  $sites_available_mode           = $nginx::params::sites_available_mode,
) inherits nginx::params {

  File {
    owner => $global_owner,
    group => $global_group,
    mode  => $global_mode,
  }

  file { $conf_dir:
    ensure => directory,
  }

  file { "${conf_dir}/conf.d":
    ensure => directory,
  }
  if $confd_purge == true {
    File["${conf_dir}/conf.d"] {
      purge   => true,
      recurse => true,
    }
  }

  file { "${conf_dir}/conf.mail.d":
    ensure => directory,
  }
  if $confd_purge == true {
    File["${conf_dir}/conf.mail.d"] {
      purge   => true,
      recurse => true,
    }
  }

  file { "${conf_dir}/conf.d/vhost_autogen.conf":
    ensure => absent,
  }

  file { "${conf_dir}/conf.mail.d/vhost_autogen.conf":
    ensure => absent,
  }

  file {$run_dir:
    ensure => directory,
  }

  file {$client_body_temp_path:
    ensure => directory,
    owner  => $daemon_user,
  }

  file {$proxy_temp_path:
    ensure => directory,
    owner  => $daemon_user,
  }

  file { "${conf_dir}/sites-available":
    owner  => $sites_available_owner,
    group  => $sites_available_group,
    mode   => $sites_available_mode,
    ensure => directory,
  }

  if $vhost_purge == true {
    File["${conf_dir}/sites-available"] {
      purge   => true,
      recurse => true,
    }
  }

  file { "${conf_dir}/sites-enabled":
    ensure => directory,
  }

  if $vhost_purge == true {
    File["${conf_dir}/sites-enabled"] {
      purge   => true,
      recurse => true,
    }
  }

  file { "${conf_dir}/sites-enabled/default":
    ensure => absent,
  }

  file { "${conf_dir}/nginx.conf":
    ensure  => file,
    content => template($conf_template),
  }

  file { "${conf_dir}/conf.d/proxy.conf":
    ensure  => file,
    content => template($proxy_conf_template),
  }

  file { "${conf_dir}/conf.d/default.conf":
    ensure => absent,
  }

  file { "${conf_dir}/conf.d/example_ssl.conf":
    ensure => absent,
  }

  file { "${temp_dir}/nginx.d":
    ensure  => absent,
    purge   => true,
    recurse => true,
    force   => true,
  }

  file { "${temp_dir}/nginx.mail.d":
    ensure  => absent,
    purge   => true,
    recurse => true,
    force   => true,
  }
}
