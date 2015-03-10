if $yaml_values == undef { $yaml_values = loadyaml('/vagrant/puphpet/config.yaml') }
if $apache_values == undef { $apache_values = $yaml_values['apache'] }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }

include puphpet::params

if hash_key_equals($apache_values, 'install', 1) {
  include apache::params

  if hash_key_equals($php_values, 'install', 1)
    and hash_key_equals($php_values, 'mod_php', 1)
  {
    $require_mod_php = true
    $apache_version  = $apache::version::default
  } else {
    $require_mod_php = false
    $apache_version  = '2.4'
  }

  if ! $require_mod_php {
    if $::operatingsystem == 'debian' {
      puphpet::apache::repo::debian{ 'do': }
    } elsif $::operatingsystem == 'ubuntu' and $::lsbdistcodename == 'precise' {
      apt::ppa { 'ppa:ondrej/apache2': require => Apt::Key['4F4EA0AAE5267A6C'] }
    } elsif $::osfamily == 'redhat' {
      puphpet::apache::repo::centos{ 'do': }
    }
  }

  $www_location          = $puphpet::params::apache_www_location
  $webroot_location      = $puphpet::params::apache_webroot_location
  $apache_provider_types = [
    'virtualbox',
    'vmware_fusion',
    'vmware_desktop',
    'parallels'
  ]

  if downcase($::provisioner_type) in $apache_provider_types {
    $webroot_group = 'www-data'
    $vhost_group   = 'www-data'
  } else {
    $webroot_group = 'www-data'
    $vhost_group   = 'www-user'
  }

  exec { "mkdir -p ${www_location}":
    creates => $www_location,
    before  => Class['apache'],
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

  if $require_mod_php {
    $mpm_module           = 'prefork'
    $disallowed_modules   = []
    $apache_php_package   = 'php'
    $fcgi_string          = ''
  } elsif hash_key_equals($hhvm_values, 'install', 1) {
    $mpm_module           = 'worker'
    $disallowed_modules   = ['php']
    $apache_php_package   = 'hhvm'
    $fcgi_string          = "127.0.0.1:${hhvm_values['settings']['port']}"
  } elsif hash_key_equals($php_values, 'install', 1) {
    $mpm_module           = 'worker'
    $disallowed_modules   = ['php']
    $apache_php_package   = 'php-fpm'
    $fcgi_string          = '127.0.0.1:9000'
  } else {
    $mpm_module           = 'worker'
    $disallowed_modules   = []
    $apache_php_package   = ''
    $fcgi_string          = ''
  }

  $sendfile = $apache_values['settings']['sendfile'] ? {
    1       => 'On',
    default => 'Off'
  }

  $apache_settings = merge($apache_values['settings'], {
    'default_vhost'  => false,
    'mpm_module'     => $mpm_module,
    'conf_template'  => $apache::params::conf_template,
    'sendfile'       => $sendfile,
    'apache_version' => $apache_version
  })

  create_resources('class', { 'apache' => $apache_settings })

  exec { "chown www-data:www-data ${www_location}":
    path    => '/bin',
    require => Class['apache'],
  }
  -> exec { "chmod 775 ${www_location}":
    path => '/bin',
  }

  if $require_mod_php and ! defined(Class['apache::mod::php']) {
    include apache::mod::php
  } elsif ! $require_mod_php {
    include puphpet::apache::fpm
  }

  if hash_key_equals($apache_values, 'mod_pagespeed', 1) {
    class { 'puphpet::apache::modpagespeed': }
  }

  if hash_key_equals($hhvm_values, 'install', 1)
    or hash_key_equals($php_values, 'install', 1)
  {
    $default_vhost_engine = 'php'
  } else {
    $default_vhost_engine = undef
  }

  if $apache_values['settings']['default_vhost'] == true {
    $apache_vhosts = merge($apache_values['vhosts'], {
      'default_vhost_80'  => {
        'servername'    => 'default',
        'docroot'       => $puphpet::params::apache_webroot_location,
        'port'          => 80,
        'default_vhost' => true,
        'engine'        => $default_vhost_engine,
      },
      'default_vhost_443' => {
        'servername'    => 'default',
        'docroot'       => $puphpet::params::apache_webroot_location,
        'port'          => 443,
        'default_vhost' => true,
        'ssl'           => 1,
        'engine'        => $default_vhost_engine,
      },
    })
  } else {
    $apache_vhosts = $apache_values['vhosts']
  }

  each( $apache_vhosts ) |$key, $vhost| {
    exec { "exec mkdir -p ${vhost['docroot']} @ key ${key}":
      command => "mkdir -p ${vhost['docroot']}",
      user    => 'www-data',
      group   => 'www-data',
      creates => $vhost['docroot'],
      require => Exec["mkdir -p ${www_location}"],
    }
    -> exec { "exec chmod -R 775 ${vhost['docroot']} @ key ${key}":
      command => "mkdir -p ${vhost['docroot']}",
      user    => 'www-data',
      group   => 'www-data',
    }

    if ! defined(File[$vhost['docroot']]) {
      file { $vhost['docroot']:
        ensure  => directory,
        group   => $vhost_group,
        mode    => '0765',
        require => [
          Exec["exec mkdir -p ${vhost['docroot']} @ key ${key}"],
          Group['www-user']
        ]
      }
    }

    $ssl = 'ssl' in $vhost and str2bool($vhost['ssl']) ? {
      true    => true,
      default => false
    }

    $ssl_cert = hash_key_true($vhost, 'ssl_cert') ? {
      true    => $vhost['ssl_cert'],
      default => $puphpet::params::ssl_cert_location
    }

    $ssl_key = hash_key_true($vhost, 'ssl_key') ? {
      true    => $vhost['ssl_key'],
      default => $puphpet::params::ssl_key_location
    }

    $ssl_chain = hash_key_true($vhost, 'ssl_chain') ? {
      true    => $vhost['ssl_chain'],
      default => undef
    }

    $ssl_certs_dir = hash_key_true($vhost, 'ssl_certs_dir') ? {
      true    => $vhost['ssl_certs_dir'],
      default => undef
    }

    $vhost_merged = delete(merge($vhost, {
      'custom_fragment' => template('puphpet/apache/custom_fragment.erb'),
      'directories'     => values_no_error($vhost['directories']),
      'ssl'             => $ssl,
      'ssl_cert'        => $ssl_cert,
      'ssl_key'         => $ssl_key,
      'ssl_chain'       => $ssl_chain,
      'ssl_certs_dir'   => $ssl_certs_dir
    }), 'engine')

    create_resources(apache::vhost, { "${key}" => $vhost_merged })

    if ! defined(Puphpet::Firewall::Port[$vhost['port']]) {
      puphpet::firewall::port { $vhost['port']: }
    }
  }

  if $::osfamily == 'debian' and ! $require_mod_php {
    file { ['/var/run/apache2/ssl_mutex']:
      ensure  => directory,
      group   => 'www-data',
      mode    => '0775',
      require => Class['apache'],
      notify  => Service['httpd'],
    }
  }

  if ! defined(Puphpet::Firewall::Port['443']) {
    puphpet::firewall::port { '443': }
  }

  if count($apache_values['modules']) > 0 {
    puphpet::apache::mod { $apache_values['modules']:
      disallowed_modules => $disallowed_modules,
    }
  }

  class { 'puphpet::ssl_cert':
    require => Class['apache'],
    notify  => Service['httpd'],
  }
}
