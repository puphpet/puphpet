# This depends on jfryman/nginx: https://github.com/jfryman/puppet-nginx.git
# Creates a new vhost
define puphpet::nginx::host (
  $fcgi_string,
  $server_name,
  $server_aliases       = [],
  $www_root,
  $listen_port,
  $location,
  $location_prepend     = [],
  $location_append      = [],
  $index_files,
  $envvars              = [],
  $ssl                  = false,
  $ssl_cert             = $puphpet::params::ssl_cert_location,
  $ssl_key              = $puphpet::params::ssl_key_location,
  $ssl_port             = '443',
  $rewrite_to_https     = false,
  $spdy                 = $nginx::params::nx_spdy,
  $engine               = false,
  $proxy                = undef,
  $client_max_body_size = '1m'
){

  $merged_server_name = concat([$server_name], $server_aliases)

  if is_array($index_files) and count($index_files) > 0 {
    $try_files_prepend = $index_files[count($index_files) - 1]
  } else {
    $try_files_prepend = ''
  }

  if $engine == 'php' {
    $try_files               = "${try_files_prepend} /index.php\$is_args\$args"
    $fastcgi_split_path_info = '^(.+\.php)(/.*)$'
    $fastcgi_index           = 'index.php'
    $fastcgi_param           = concat([
      'SCRIPT_FILENAME $request_filename'
    ], $envvars)
    $fastcgi_pass_hash       = value_true($fcgi_string) ? {
      true    => {'fastcgi_pass' => $fcgi_string},
      default => {}
    }
  } else {
    $try_files               = "${try_files_prepend} /index.html"
    $fastcgi_split_path_info = '^(.+\.html)(/.+)$'
    $fastcgi_index           = 'index.html'
    $fastcgi_param           = $envvars
    $fastcgi_pass_hash       = {}
  }

  $ssl_set = value_true($ssl) ? {
    true    => true,
    default => false,
  }
  $ssl_cert_set = value_true($ssl_cert) ? {
    true    => $ssl_cert,
    default => $puphpet::params::ssl_cert_location,
  }
  $ssl_key_set = value_true($ssl_key) ? {
    true    => $ssl_key,
    default => $puphpet::params::ssl_key_location,
  }
  $ssl_port_set = value_true($ssl_port) ? {
    true    => $ssl_port,
    default => '443',
  }
  $rewrite_to_https_set = value_true($rewrite_to_https) ? {
    true    => true,
    default => false,
  }
  $spdy_set = value_true($spdy) ? {
    true    => on,
    default => off,
  }
  $www_root_set = value_true($proxy) ? {
    true    => undef,
    default => $www_root,
  }

  $location_cfg_append  = merge({
    'fastcgi_split_path_info' => $fastcgi_split_path_info,
    'fastcgi_param'           => $fastcgi_param,
    'fastcgi_index'           => $fastcgi_index,
    'include'                 => 'fastcgi_params'
  }, $fastcgi_pass_hash)

  nginx::resource::vhost { $server_name:
    server_name          => $merged_server_name,
    www_root             => $www_root_set,
    proxy                => $proxy,
    listen_port          => $listen_port,
    index_files          => $index_files,
    try_files            => ['$uri', '$uri/', $try_files],
    ssl                  => $ssl_set,
    ssl_cert             => $ssl_cert_set,
    ssl_key              => $ssl_key_set,
    ssl_port             => $ssl_port_set,
    rewrite_to_https     => $rewrite_to_https_set,
    spdy                 => $spdy_set,
    vhost_cfg_append     => {
      sendfile => 'off'
    },
    client_max_body_size => $client_max_body_size
  }

  if $engine == 'php' and $www_root_set != undef {
    nginx::resource::location { "${server_name}-php":
      ensure                      => present,
      vhost                       => $server_name,
      location                    => "~ ${location}",
      proxy                       => undef,
      try_files                   => [
        '$uri', '$uri/', "/${try_files}\$is_args\$args"
      ],
      ssl                         => $ssl_set,
      ssl_only                    => $ssl_set,
      www_root                    => $www_root,
      location_cfg_append         => $location_cfg_append,
      location_custom_cfg_prepend => $location_prepend,
      location_custom_cfg_append  => $location_append,
      notify                      => Class['nginx::service'],
    }
  }

}
