if $yaml_values == undef { $yaml_values = merge_yaml('/vagrant/puphpet/config.yaml', '/vagrant/puphpet/config-custom.yaml') }
if $nginx_values == undef { $nginx_values = $yaml_values['nginx'] }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }

include puphpet::params

if hash_key_equals($nginx_values, 'install', 1) {
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
  $nginx_settings = delete(merge({},
    $nginx_values['settings']
  ), 'default_vhost')

  create_resources('class', { 'nginx' => $nginx_settings })

  $nginx_upstreams = merge({}, $nginx_values['upstreams'])

  each( $nginx_upstreams ) |$key, $upstream| {
    $upstream_name = $upstream['name']

    $upstream_merged = delete($upstream, ['name'])

    create_resources(nginx::resource::upstream, {
      "${upstream_name}" => $upstream_merged
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

  # Creates a default vhost entry if user chose to do so
  if hash_key_equals($nginx_values['settings'], 'default_vhost', 1) {
    $nginx_vhosts = merge($nginx_values['vhosts'], {
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
            'try_files'             => ['$uri', '$uri/', 'index.php',],
            'fastcgi'               => '',
            'fastcgi_index'         => '',
            'fastcgi_split_path'    => '',
            'fast_cgi_params_extra' => [],
            'index_files'           => [],
          },
          {
            'location'              => '~ \.php$',
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
    $nginx_vhosts = $nginx_values['vhosts']
  }

  each( $nginx_vhosts ) |$key, $vhost| {
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
    $rewrite_to_https = array_true($vhost, 'rewrite_to_https') ? {
      true    => true,
      default => false,
    }

    $vhost_cfg_append = deep_merge(
      {'vhost_cfg_append' => {'sendfile' => 'off'}},
      $vhost
    )

    # puppet-nginx is stupidly strict about ssl value datatypes
    $vhost_merged = delete(merge($vhost_cfg_append, {
      'server_name'          => $server_names,
      'use_default_location' => false,
      'ssl'                  => $ssl,
      'ssl_cert'             => $ssl_cert,
      'ssl_key'              => $ssl_key,
      'ssl_port'             => $ssl_port,
      'rewrite_to_https'     => $rewrite_to_https,
    }), ['server_aliases', 'proxy', 'locations'])

    create_resources(nginx::resource::vhost, { "${key}" => $vhost_merged })

    # config file could contain no vhost.locations key
    $nginx_locations = array_true($vhost, 'locations') ? {
      true    => $vhost['locations'],
      default => { }
    }

    each( $nginx_locations ) |$lkey, $location| {
      # remove empty values
      $location_trimmed = merge({
        'fast_cgi_params_extra' => [],
      }, delete_values($location, ''))

      # Takes gui ENV vars: fastcgi_param {ENV_NAME} {VALUE}
      $location_custom_cfg_append = prefix(
        $location_trimmed['fast_cgi_params_extra'],
        'fastcgi_param '
      )

      # separate from $location_trimmed because some values
      # really need to be set to a default.
      # Removes fast_cgi_params_extra because it only exists in gui
      # not puppet-nginx
      $location_no_root = delete(merge({
        'vhost'                      => $key,
        'ssl'                        => $ssl,
        'location_custom_cfg_append' => $location_custom_cfg_append,
      }, $location_trimmed), 'fast_cgi_params_extra')

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

  if defined(File[$puphpet::params::nginx_webroot_location]) {
    file { "${puphpet::params::nginx_webroot_location}/index.html":
      ensure  => present,
      owner   => 'root',
      group   => $webroot_group,
      mode    => '0664',
      source  => 'puppet:///modules/puphpet/webserver_landing.erb',
      replace => true,
      require => File[$puphpet::params::nginx_webroot_location],
    }
  }
}
