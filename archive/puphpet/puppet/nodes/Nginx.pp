if $yaml_values == undef { $yaml_values = loadyaml('/vagrant/puphpet/config.yaml') }
if $nginx_values == undef { $nginx_values = $yaml_values['nginx'] }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }

include puphpet::params

if hash_key_equals($nginx_values, 'install', 1) {
  include nginx::params

  Class['puphpet::ssl_cert']
  -> Nginx::Resource::Vhost <| |>

  class { 'puphpet::ssl_cert': }

  $www_location         = $puphpet::params::nginx_www_location
  $webroot_location     = $puphpet::params::nginx_webroot_location
  $nginx_provider_types = [
    'virtualbox',
    'vmware_fusion',
    'vmware_desktop',
    'parallels'
  ]

  if downcase($::provisioner_type) in $nginx_provider_types {
    $webroot_group = 'www-data'
    $vhost_group   = 'www-data'
  } else {
    $webroot_group = 'www-data'
    $vhost_group   = 'www-user'
  }

  exec { "mkdir -p ${www_location}":
    creates => $www_location,
    before  => Class['nginx'],
  }
  -> exec { "chown www-data:www-data ${www_location} && chmod 775 ${www_location}":
    path => '/bin',
  }

  exec { "mkdir -p ${webroot_location}":
    creates => $webroot_location,
    require => Exec["mkdir -p ${www_location}"],
  }

  if ! defined(File[$webroot_location]) {
    file { $webroot_location:
      ensure  => directory,
      group   => $webroot_group,
      mode    => '0775',
      require => [
        Exec["mkdir -p ${webroot_location}"],
        Group['www-data']
      ],
    }
  }

  if hash_key_equals($hhvm_values, 'install', 1) {
    $fcgi_string = "127.0.0.1:${hhvm_values['settings']['port']}"
  } elsif hash_key_equals($php_values, 'install', 1) {
    $fcgi_string = '127.0.0.1:9000'
  } else {
    $fcgi_string = false
  }

  if $::osfamily == 'redhat' {
    file { '/usr/share/nginx':
      ensure  => directory,
      mode    => '0775',
      owner   => 'www-data',
      group   => 'www-data',
      require => Group['www-data'],
      before  => Package['nginx']
    }
  }

  if hash_key_equals($hhvm_values, 'install', 1)
    or hash_key_equals($php_values, 'install', 1)
  {
    $default_vhost = {
      'server_name'          => '_',
      'server_aliases'       => [],
      'www_root'             => $puphpet::params::nginx_webroot_location,
      'proxy'                => '',
      'listen_port'          => 80,
      'location'             => '\.php$',
      'location_prepend'     => [],
      'location_append'      => [],
      'index_files'          => [
        'index', 'index.html', 'index.htm', 'index.php'
      ],
      'envvars'              => [],
      'ssl'                  => '0',
      'ssl_cert'             => '',
      'ssl_key'              => '',
      'engine'               => 'php',
      'client_max_body_size' => '1m'
    }
  } else {
    $default_vhost = {
      'server_name'          => '_',
      'server_aliases'       => [],
      'www_root'             => $puphpet::params::nginx_webroot_location,
      'proxy'                => '',
      'listen_port'          => 80,
      'location'             => '/',
      'location_prepend'     => [],
      'location_append'      => [],
      'index_files'          => ['index', 'index.html', 'index.htm'],
      'envvars'              => [],
      'ssl'                  => '0',
      'ssl_cert'             => '',
      'ssl_key'              => '',
      'engine'               => false,
      'client_max_body_size' => '1m'
    }
  }

  class { 'nginx': }

  exec { "chown www-data:www-data ${www_location}":
    path    => '/bin',
    require => Class['nginx'],
  }
  -> exec { "chmod 775 ${www_location}":
    path => '/bin',
  }

  if hash_key_equals($nginx_values['settings'], 'default_vhost', 1) {
    $nginx_vhosts = merge($nginx_values['vhosts'], {
      'default' => $default_vhost,
    })

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
    if ! defined($vhost['proxy']) or $vhost['proxy'] == '' {
      exec { "exec mkdir -p ${vhost['www_root']} @ key ${key}":
        command => "mkdir -p ${vhost['www_root']}",
        user    => 'www-data',
        group   => 'www-data',
        creates => $vhost['www_root'],
        require => Exec["mkdir -p ${www_location}"],
      }
      -> exec { "exec chmod -R 775 ${vhost['www_root']} @ key ${key}":
        command => "mkdir -p ${vhost['www_root']}",
        user    => 'www-data',
        group   => 'www-data',
      }

      if ! defined(File[$vhost['www_root']]) {
        file { $vhost['www_root']:
          ensure  => directory,
          group   => $vhost_group,
          mode    => '0765',
          require => [
            Exec["exec mkdir -p ${vhost['www_root']} @ key ${key}"],
            Group['www-user']
          ]
        }
      }
    }

    if ! defined(Puphpet::Firewall::Port[$vhost['listen_port']]) {
      puphpet::firewall::port { $vhost['listen_port']: }
    }

    $vhost_merged = merge($vhost, {
      'fcgi_string' => $fcgi_string,
    })

    create_resources(puphpet::nginx::host, { "${key}" => $vhost_merged })
  }

  if ! defined(Puphpet::Firewall::Port['443']) {
    puphpet::firewall::port { '443': }
  }

  if is_hash($nginx_values['upstreams'])
    and count($nginx_values['upstreams']) > 0
  {
    notify{ 'Adding upstreams': }
    create_resources(puphpet::nginx::upstream, $nginx_values['upstreams'])
  }
}
