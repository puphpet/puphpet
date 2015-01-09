if $yaml_values == undef { $yaml_values = loadyaml('/vagrant/puphpet/config.yaml') }
if $apache_values == undef { $apache_values = $yaml_values['apache'] }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }

include puphpet::params

if hash_key_equals($apache_values, 'install', 1) {
  include apache::params

  if hash_key_equals($php_values, 'install', 1) and hash_key_equals($php_values, 'mod_php', 1) {
    $require_mod_php = true
    $apache_version  = $apache::version::default
  } else {
    $require_mod_php = false
    $apache_version  = '2.4'
  }

  if ! $require_mod_php {
    if $::operatingsystem == 'debian' {
      apache_debian_repo{ 'do': }
    } elsif $::operatingsystem == 'ubuntu' and $::lsbdistcodename == 'precise' {
      apt::ppa { 'ppa:ondrej/apache2': require => Apt::Key['4F4EA0AAE5267A6C'] }
    } elsif $::osfamily == 'redhat' {
      apache_centos{ 'do': }
    }
  }

  $webroot_location      = $puphpet::params::apache_webroot_location
  $apache_provider_types = [
    'virtualbox',
    'vmware_fusion',
    'vmware_desktop',
    'parallels'
  ]

  exec { "mkdir -p ${webroot_location}":
    creates => $webroot_location,
  }

  if downcase($::provisioner_type) in $apache_provider_types {
    $webroot_location_group = 'www-data'
    $vhost_docroot_group    = 'www-data'
  } else {
    $webroot_location_group = undef
    $vhost_docroot_group    = 'www-user'
  }

  if ! defined(File[$webroot_location]) {
    file { $webroot_location:
      ensure  => directory,
      group   => $webroot_location_group,
      mode    => 0775,
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
    $mpm_module           = 'prefork'
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
        'docroot'       => '/var/www/default',
        'port'          => 80,
        'default_vhost' => true,
        'engine'        => $default_vhost_engine,
      },
      'default_vhost_443' => {
        'servername'    => 'default',
        'docroot'       => '/var/www/default',
        'port'          => 443,
        'default_vhost' => true,
        'ssl'           => 1,
        'engine'        => $default_vhost_engine,
      },
    })
  } else {
    $apache_vhosts = $apache_values['vhosts']
  }

  if count($apache_vhosts) > 0 {
    each( $apache_vhosts ) |$key, $vhost| {
      exec { "exec mkdir -p ${vhost['docroot']} @ key ${key}":
        command => "mkdir -p ${vhost['docroot']}",
        creates => $vhost['docroot'],
      }

      if ! defined(File[$vhost['docroot']]) {
        file { $vhost['docroot']:
          ensure  => directory,
          group   => $vhost_docroot_group,
          mode    => 0765,
          require => [
            Exec["exec mkdir -p ${vhost['docroot']} @ key ${key}"],
            Group['www-user']
          ]
        }
      }

      $vhost_merged = delete(merge($vhost, {
        'custom_fragment' => template('puphpet/apache/custom_fragment.erb'),
        'directories'     => values_no_error($vhost['directories']),
        'ssl'             => 'ssl' in $vhost and str2bool($vhost['ssl']) ? { true => true, default => false },
        'ssl_cert'        => hash_key_true($vhost, 'ssl_cert')      ? { true => $vhost['ssl_cert'],      default => $puphpet::params::ssl_cert_location },
        'ssl_key'         => hash_key_true($vhost, 'ssl_key')       ? { true => $vhost['ssl_key'],       default => $puphpet::params::ssl_key_location },
        'ssl_chain'       => hash_key_true($vhost, 'ssl_chain')     ? { true => $vhost['ssl_chain'],     default => undef },
        'ssl_certs_dir'   => hash_key_true($vhost, 'ssl_certs_dir') ? { true => $vhost['ssl_certs_dir'], default => undef }
      }), 'engine')

      create_resources(apache::vhost, { "${key}" => $vhost_merged })

      if ! defined(Firewall["100 tcp/${vhost['port']}"]) {
        firewall { "100 tcp/${vhost['port']}":
          port   => $vhost['port'],
          proto  => tcp,
          action => 'accept',
        }
      }
    }
  }


  if $::osfamily == 'debian' and ! $require_mod_php {
    file { ['/var/run/apache2/ssl_mutex']:
      ensure  => directory,
      group   => 'www-data',
      mode    => 0775,
      require => Class['apache'],
      notify  => Service['httpd'],
    }
  }

  if ! defined(Firewall['100 tcp/443']) {
    firewall { '100 tcp/443':
      port   => 443,
      proto  => tcp,
      action => 'accept',
    }
  }

  if count($apache_values['modules']) > 0 {
    apache_mod { $apache_values['modules']: }
  }

  class { 'puphpet::ssl_cert':
    require => Class['apache'],
    notify  => Service['httpd'],
  }
}

define apache_debian_repo {
  apt::source { 'd7031.de':
    location          => 'http://www.d7031.de/debian/',
    release           => 'wheezy-experimental',
    repos             => 'main',
    required_packages => 'debian-keyring debian-archive-keyring',
    key               => '9EB5E8A3DF17D0B3',
    key_server        => 'hkp://keyserver.ubuntu.com:80',
    include_src       => true
  }
}

define apache_centos {
  $httpd_url               = 'http://repo.puphpet.com/centos/httpd24/httpd-2.4.10-RPM-full.x86_64.tgz'
  $httpd_download_location = '/.puphpet-stuff/httpd-2.4.10-RPM-full.x86_64.tgz'
  $httpd_tar               = "tar xzvf '${httpd_download_location}'"
  $extract_location        = '/.puphpet-stuff/httpd-2.4.10-RPM-full.x86_64'

  exec { 'download httpd-2.4.10':
    creates => $httpd_download_location,
    command => "wget --quiet --tries=5 --connect-timeout=10 -O '${httpd_download_location}' '${httpd_url}'",
    timeout => 3600,
    path    => '/usr/bin',
  } ->
  exec { 'untar httpd-2.4.10':
    creates => $extract_location,
    command => $httpd_tar,
    cwd     => '/.puphpet-stuff',
    path    => '/bin',
  } ->
  exec { 'install httpd-2.4.10':
    creates => '/etc/httpd',
    command => 'yum -y localinstall * --skip-broken',
    cwd     => $extract_location,
    path    => '/usr/bin',
  }

  exec { 'rm /etc/httpd/conf.d/systemd.load':
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    onlyif  => 'test -f /etc/httpd/conf.d/systemd.load',
    require => Class['apache'],
    notify  => Service['httpd'],
  }
}

define apache_mod {
  if ! defined(Class["apache::mod::${name}"]) and !($name in $disallowed_modules) {
    class { "apache::mod::${name}": }
  }
}
