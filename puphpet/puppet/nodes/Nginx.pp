class puphpet_nginx (
  $nginx
) {

  include nginx::params

  Class['puphpet::ssl_cert']
  -> Nginx::Resource::Vhost <| |>

  class { 'puphpet::ssl_cert': }

  $www_location  = $puphpet::params::nginx_www_location
  $webroot_user  = 'www-data'
  $webroot_group = 'www-data'

  if ! defined(File[$www_location]) {
    file { $www_location:
      ensure  => directory,
      owner   => 'root',
      group   => $webroot_group,
      mode    => '0775',
      before  => Class['nginx'],
      require => Group[$webroot_group],
    }
  }

  if $::osfamily == 'redhat' {
    file { '/usr/share/nginx':
      ensure  => directory,
      mode    => '0775',
      owner   => $webroot_user,
      group   => $webroot_group,
      require => Group[$webroot_group],
      before  => Package['nginx']
    }
  }

  # Merges into empty array for now
  $settings = delete(merge({},
    $nginx['settings']
  ), 'default_vhost')

  create_resources('class', { 'nginx' => $settings })

  $upstreams = merge({}, $nginx['upstreams'])

  each( $upstreams ) |$key, $upstream| {
    $name   = $upstream['name']
    $merged = delete($upstream, ['name'])

    create_resources(nginx::resource::upstream, {
      "${name}" => $merged
    })

    each( $upstream['members'] ) |$key, $member| {
      $member_array = $package_array = split($member, ':')

      if count($member_array) == 2
        and ! defined(Puphpet::Firewall::Port[$member_array[1]])
      {
        puphpet::firewall::port { $member_array[1]: }
      }
    }
  }

  $proxies = array_true($proxy, 'proxies') ? {
    true    => $proxy['proxies'],
    default => [],
  }

  each( $proxies ) |$key, $proxy| {
    $proxy_redirect = array_true($proxy, 'proxy_redirect') ? {
      true    => $proxy['proxy_redirect'],
      default => undef,
    }
    $proxy_read_timeout = array_true($proxy, 'proxy_read_timeout') ? {
      true    => $proxy['proxy_read_timeout'],
      default => $nginx::config::proxy_read_timeout,
    }
    $proxy_connect_timeout = array_true($proxy, 'proxy_connect_timeout') ? {
      true    => $proxy['proxy_connect_timeout'],
      default => $nginx::config::proxy_connect_timeout,
    }
    $proxy_set_header = array_true($proxy, 'proxy_set_header') ? {
      true    => $proxy['proxy_set_header'],
      default => [],
    }
    $proxy_cache = array_true($proxy, 'proxy_cache') ? {
      true    => $proxy['proxy_cache'],
      default => false,
    }
    $proxy_cache_valid = array_true($proxy, 'proxy_cache_valid') ? {
      true    => $proxy['proxy_cache_valid'],
      default => false,
    }
    $proxy_method = array_true($proxy, 'proxy_method') ? {
      true    => $proxy['proxy_method'],
      default => undef,
    }
    $proxy_set_body = array_true($proxy, 'proxy_set_body') ? {
      true    => $proxy['proxy_set_body'],
      default => undef,
    }

    $merged = merge($proxy, {
      'proxy_redirect'        => $proxy_redirect,
      'proxy_read_timeout'    => $proxy_read_timeout,
      'proxy_connect_timeout' => $proxy_connect_timeout,
      'proxy_set_header'      => $proxy_set_header,
      'proxy_cache'           => $proxy_cache,
      'proxy_cache_valid'     => $proxy_cache_valid,
      'proxy_method'          => $proxy_method,
      'proxy_set_body'        => $proxy_set_body,
    })

    create_resources(nginx::resource::vhost, { "${key}" => $merged })
  }

  # Creates a default vhost entry if user chose to do so
  if array_true($nginx['settings'], 'default_vhost') {
    $vhosts = merge($nginx['vhosts'], {
      '_'       => {
        'server_name'          => '_',
        'server_aliases'       => [],
        'www_root'             => $puphpet::params::nginx_webroot_location,
        'listen_port'          => 80,
        'client_max_body_size' => '1m',
        'use_default_location' => false,
        'vhost_cfg_append'     => {'sendfile' => 'off'},
        'index_files'          => [
          'index', 'index.html', 'index.htm', 'index.php'
        ],
        'locations'            => [
          {
            'location'              => '/',
            'autoindex'             => 'off',
            'internal'              => false,
            'try_files'             => ['$uri', '$uri/', 'index.php',],
            'fastcgi'               => '',
            'fastcgi_index'         => '',
            'fastcgi_split_path'    => '',
            'fast_cgi_params_extra' => [],
            'index_files'           => [],
          },
          {
            'location'              => '~ \.php$',
            'autoindex'             => 'off',
            'internal'              => false,
            'try_files'             => [
              '$uri', '$uri/', 'index.php', '/index.php$is_args$args'
            ],
            'fastcgi'               => '127.0.0.1:9000',
            'fastcgi_index'         => 'index.php',
            'fastcgi_split_path'    => '^(.+\.php)(/.*)$',
            'fast_cgi_params_extra' => [
              'SCRIPT_FILENAME $request_filename',
              'APP_ENV dev',
            ],
            'index_files'           => [],
          }
        ]
      },
    })

    # Force nginx to be managed exclusively through puppet module
    if ! defined(File[$puphpet::params::nginx_default_conf_location]) {
      file { $puphpet::params::nginx_default_conf_location:
        ensure  => absent,
        require => Package['nginx'],
        notify  => Class['nginx::service'],
      }
    }
  } else {
    $vhosts = $nginx['vhosts']
  }

  each( $vhosts ) |$key, $vhost| {
    exec { "exec mkdir -p ${vhost['www_root']} @ key ${key}":
      command => "mkdir -p ${vhost['www_root']}",
      user    => $webroot_user,
      group   => $webroot_group,
      creates => $vhost['www_root'],
      require => File[$www_location],
    }

    if ! defined(File[$vhost['www_root']]) {
      file { $vhost['www_root']:
        ensure  => directory,
        mode    => '0775',
        require => Exec["exec mkdir -p ${vhost['www_root']} @ key ${key}"],
      }
    }

    # the gui passes "server_name" and "server_aliases"
    # "server_aliases" is not actually in puppet-nginx
    $server_names = unique(flatten(
      concat([$vhost['server_name']], $vhost['server_aliases'])
    ))

    $allowed_ciphers = [
      'ECDHE-RSA-AES256-GCM-SHA384', 'ECDHE-RSA-AES128-GCM-SHA256',
      'DHE-RSA-AES256-GCM-SHA384', 'DHE-RSA-AES128-GCM-SHA256',
      'ECDHE-RSA-AES256-SHA384', 'ECDHE-RSA-AES128-SHA256', 'ECDHE-RSA-AES256-SHA',
      'ECDHE-RSA-AES128-SHA', 'DHE-RSA-AES256-SHA256', 'DHE-RSA-AES128-SHA256',
      'DHE-RSA-AES256-SHA', 'DHE-RSA-AES128-SHA', 'ECDHE-RSA-DES-CBC3-SHA',
      'EDH-RSA-DES-CBC3-SHA', 'AES256-GCM-SHA384', 'AES128-GCM-SHA256', 'AES256-SHA256',
      'AES128-SHA256', 'AES256-SHA', 'AES128-SHA', 'DES-CBC3-SHA',
      'HIGH', '!aNULL', '!eNULL', '!EXPORT', '!DES', '!MD5', '!PSK', '!RC4'
    ]

    $ssl = array_true($vhost, 'ssl') ? {
      true    => true,
      default => false,
    }
    $ssl_cert = array_true($vhost, 'ssl_cert') ? {
      true    => $vhost['ssl_cert'],
      default => $puphpet::params::ssl_cert_location,
    }
    $ssl_key = array_true($vhost, 'ssl_key') ? {
      true    => $vhost['ssl_key'],
      default => $puphpet::params::ssl_key_location,
    }
    $ssl_port = array_true($vhost, 'ssl_port') ? {
      true    => $vhost['ssl_port'],
      default => '443',
    }
    $ssl_protocols = array_true($vhost, 'ssl_protocols') ? {
      true    => $vhost['ssl_protocols'],
      default => 'TLSv1 TLSv1.1 TLSv1.2',
    }
    $ssl_ciphers = array_true($vhost, 'ssl_ciphers') ? {
      true    => $vhost['ssl_ciphers'],
      default => join($allowed_ciphers, ':'),
    }
    $rewrite_to_https = $ssl and array_true($vhost, 'rewrite_to_https') ? {
      true    => true,
      default => undef,
    }

    $vhost_cfg_append = deep_merge(
      {'vhost_cfg_append' => {'sendfile' => 'off'}},
      $vhost
    )

    # puppet-nginx is stupidly strict about ssl value datatypes
    $merged = delete(merge($vhost_cfg_append, {
      'server_name'          => $server_names,
      'use_default_location' => false,
      'ssl'                  => $ssl,
      'ssl_cert'             => $ssl_cert,
      'ssl_key'              => $ssl_key,
      'ssl_port'             => $ssl_port,
      'ssl_protocols'        => $ssl_protocols,
      'ssl_ciphers'          => "\"${ssl_ciphers}\"",
      'rewrite_to_https'     => $rewrite_to_https,
    }), ['server_aliases', 'proxy', 'locations'])

    create_resources(nginx::resource::vhost, { "${key}" => $merged })

    # config file could contain no vhost.locations key
    $locations = array_true($vhost, 'locations') ? {
      true    => $vhost['locations'],
      default => { }
    }

    each( $locations ) |$lkey, $location| {
      if $location['autoindex'] or $location['autoindex'] == 'on' {
        $autoindex = 'on'
      } else {
        $autoindex = 'off'
      }

      if array_true($location, 'internal') and $location['internal'] != 'off' {
        $internal = true
      } else {
        $internal = false
      }

      # remove empty values
      $location_trimmed = merge({
        'fast_cgi_params_extra' => [],
      }, delete_values($location, ''))

      # transforms user-data to expected
      $location_custom_data = merge($location_trimmed, {
        'autoindex' => $autoindex,
        'internal'  => $internal,
      })

      # Takes gui ENV vars: fastcgi_param {ENV_NAME} {VALUE}
      $location_custom_cfg_append = prefix(
        $location_custom_data['fast_cgi_params_extra'],
        'fastcgi_param '
      )

      # separate from $location_custom_data because some values
      # really need to be set to a default.
      # Removes fast_cgi_params_extra because it only exists in gui
      # not puppet-nginx
      $location_no_root = delete(merge({
        'vhost'                      => $key,
        'ssl'                        => $ssl,
        'location_custom_cfg_append' => $location_custom_cfg_append,
      }, $location_custom_data), 'fast_cgi_params_extra')

      # If www_root was removed with all the trimmings,
      # add it back it
      if ! defined($location_no_root['fastcgi'])
        or empty($location_no_root['fastcgi'])
      {
        $location_merged = merge({
          'www_root' => $vhost['www_root'],
        }, $location_no_root)
      } else {
        $location_merged = $location_no_root
      }

      create_resources(nginx::resource::location, { "${lkey}" => $location_merged })
    }

    if ! defined(Puphpet::Firewall::Port[$vhost['listen_port']]) {
      puphpet::firewall::port { $vhost['listen_port']: }
    }
  }

  if ! defined(Puphpet::Firewall::Port['443']) {
    puphpet::firewall::port { '443': }
  }

  $default_vhost_index_file =
    "${puphpet::params::nginx_webroot_location}/index.html"

  $default_vhost_source_file =
    '/vagrant/puphpet/puppet/modules/puphpet/files/webserver_landing.html'

  exec { "Set ${default_vhost_index_file} contents":
    command => "cat ${default_vhost_source_file} > ${default_vhost_index_file} && \
                chmod 644 ${default_vhost_index_file} && \
                chown root ${default_vhost_index_file} && \
                chgrp ${webroot_group} ${default_vhost_index_file} && \
                touch /.puphpet-stuff/default_vhost_index_file_set",
    returns => [0, 1],
    creates => '/.puphpet-stuff/default_vhost_index_file_set',
    require => File[$puphpet::params::nginx_webroot_location],
  }

}
