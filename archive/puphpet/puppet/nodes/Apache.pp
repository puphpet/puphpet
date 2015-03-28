if $yaml_values == undef { $yaml_values = merge_yaml('/vagrant/puphpet/config.yaml', '/vagrant/puphpet/config-custom.yaml') }
if $apache_values == undef { $apache_values = $yaml_values['apache'] }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }

include puphpet::params
include puphpet::apache::params

if array_true($apache_values, 'install') {
  include ::apache::params

  class { 'puphpet::apache::repo': }

  $apache_version = '2.4'
  $apache_modules = delete($apache_values['modules'], 'pagespeed')

  if array_true($php_values, 'install') {
    $php_engine    = true
    $php_fcgi_port = access($php_values, 'fpm_settings.port')
  } elsif array_true($hhvm_values, 'install') {
    $php_engine    = true
    $php_fcgi_port = access($hhvm_values, 'settings.port')
  } else {
    $php_engine    = false
  }

  $mpm_module = 'worker'

  $sethandler_string = $php_engine ? {
    true    => "proxy:fcgi://127.0.0.1:${php_fcgi_port}",
    default => 'default-handler'
  }

  $www_root      = $puphpet::apache::params::www_root
  $webroot_user  = 'www-data'
  $webroot_group = 'www-data'

  # centos 2.4 installation creates webroot automatically,
  # requiring us to manually set owner and permissions via exec
  exec { 'Create apache webroot':
    command => "mkdir -p ${www_root} && \
                chown root:${webroot_group} ${www_root} && \
                chmod 775 ${www_root} && \
                touch /.puphpet-stuff/apache-webroot-created",
    creates => '/.puphpet-stuff/apache-webroot-created',
    require => [
      Group[$webroot_group],
      Class['apache']
    ],
  }

  $sendfile = array_true($apache_values['settings'], 'sendfile') ? {
    true    => 'On',
    default => 'Off'
  }

  $apache_settings = merge($apache_values['settings'], {
    'default_vhost'  => false,
    'mpm_module'     => $mpm_module,
    'conf_template'  => $::apache::params::conf_template,
    'sendfile'       => $sendfile,
    'apache_version' => $apache_version
  })

  create_resources('class', { 'apache' => $apache_settings })

  if $php_engine {
    $default_vhost_directories = {'default' => {
      'provider'        => 'directory',
      'path'            => $puphpet::apache::params::default_vhost_dir,
      'options'         => ['Indexes', 'FollowSymlinks', 'MultiViews'],
      'allow_override'  => ['All'],
      'require'         => ['all granted'],
      'files_match'     => {'php_match' => {
        'provider'   => 'filesmatch',
        'path'       => '\.php$',
        'sethandler' => $sethandler_string,
      }},
      'custom_fragment' => '',
    }}
  } else {
    $default_vhost_directories = {'default' => {
      'provider'        => 'directory',
      'path'            => $puphpet::apache::params::default_vhost_dir,
      'options'         => ['Indexes', 'FollowSymlinks', 'MultiViews'],
      'allow_override'  => ['All'],
      'require'         => ['all granted'],
      'files_match'     => {},
      'custom_fragment' => '',
    }}
  }

  if array_true($apache_values['settings'], 'default_vhost') {
    $apache_default_vhosts = {
      'default_vhost_80'  => {
        'servername'    => 'default',
        'docroot'       => $puphpet::apache::params::default_vhost_dir,
        'port'          => 80,
        'directories'   => $default_vhost_directories,
        'default_vhost' => true,
      },
      'default_vhost_443' => {
        'servername'    => 'default',
        'docroot'       => $puphpet::apache::params::default_vhost_dir,
        'port'          => 443,
        'directories'   => $default_vhost_directories,
        'default_vhost' => true,
        'ssl'           => 1,
      },
    }
  } else {
    $apache_default_vhosts = {}
  }

  # config file could contain no vhosts key
  $apache_vhosts_merged = array_true($apache_values, 'vhosts') ? {
    true    => merge($apache_values['vhosts'], $apache_default_vhosts),
    default => $apache_default_vhosts,
  }

  each( $apache_vhosts_merged ) |$key, $vhost| {
    exec { "exec mkdir -p ${vhost['docroot']} @ key ${key}":
      command => "mkdir -m 775 -p ${vhost['docroot']}",
      user    => $webroot_user,
      group   => $webroot_group,
      creates => $vhost['docroot'],
      require => Exec['Create apache webroot'],
    }

    $ssl = array_true($vhost, 'ssl')

    $ssl_cert = array_true($vhost, 'ssl_cert') ? {
      true    => $vhost['ssl_cert'],
      default => $puphpet::params::ssl_cert_location
    }

    $ssl_key = array_true($vhost, 'ssl_key') ? {
      true    => $vhost['ssl_key'],
      default => $puphpet::params::ssl_key_location
    }

    $ssl_chain = array_true($vhost, 'ssl_chain') ? {
      true    => $vhost['ssl_chain'],
      default => undef
    }

    $ssl_certs_dir = array_true($vhost, 'ssl_certs_dir') ? {
      true    => $vhost['ssl_certs_dir'],
      default => undef
    }

    if array_true($vhost, 'directories') {
      $directories_hash   = $vhost['directories']
      $files_match        = template('puphpet/apache/files_match.erb')
      $directories_merged = merge($vhost['directories'], hash_eval($files_match))
    } else {
      $directories_merged = {}
    }

    $vhost_custom_fragment = array_true($vhost, 'custom_fragment') ? {
      true    => file($vhost['custom_fragment']),
      default => '',
    }

    $vhost_merged = merge($vhost, {
      'directories'     => values_no_error($directories_merged),
      'ssl'             => $ssl,
      'ssl_cert'        => $ssl_cert,
      'ssl_key'         => $ssl_key,
      'ssl_chain'       => $ssl_chain,
      'ssl_certs_dir'   => $ssl_certs_dir,
      'custom_fragment' => $vhost_custom_fragment,
      'manage_docroot'  => false
    })

    create_resources(::apache::vhost, { "${key}" => $vhost_merged })

    if ! defined(Puphpet::Firewall::Port[$vhost['port']]) {
      puphpet::firewall::port { $vhost['port']: }
    }
  }

  if $::osfamily == 'debian' {
    file { '/var/run/apache2/ssl_mutex':
      ensure  => directory,
      group   => $webroot_group,
      mode    => '0775',
      require => Class['apache'],
      notify  => Service['httpd'],
    }
  }

  if ('proxy_fcgi' in $apache_values['modules']) {
    include puphpet::apache::proxy_fcgi
  }

  # mod_pagespeed needs some extra love
  if 'pagespeed' in $apache_values['modules'] {
    class { 'puphpet::apache::modpagespeed': }
  }

  each( $apache_modules ) |$module| {
    if ! defined(Apache::Mod[$module]) {
      apache::mod { $module: }
    }
  }

  class { 'puphpet::ssl_cert':
    require => Class['apache'],
    notify  => Service['httpd'],
  }

  $default_vhost_index_file =
    "${puphpet::apache::params::default_vhost_dir}/index.html"

  if ! defined(File[$default_vhost_index_file]) {
    file { $default_vhost_index_file:
      ensure  => present,
      owner   => 'root',
      group   => $webroot_group,
      mode    => '0664',
      source  => 'puppet:///modules/puphpet/webserver_landing.erb',
      replace => true,
      require => Exec['Create apache webroot'],
    }
  }
}
