if $php_values == undef { $php_values = hiera_hash('php', false) }
if $mailcatcher_values == undef { $mailcatcher_values = hiera_hash('mailcatcher', false) }

include puphpet::params

if array_true($php_values, 'install') {
  include ::php::params

  class { 'puphpet::php::settings':
    version_string => $php_values['settings']['version'],
  }

  $php_version  = $puphpet::php::settings::version
  $php_base_ini = $puphpet::php::settings::base_ini
  $php_fpm_ini  = $puphpet::php::settings::fpm_ini
  $php_package  = $puphpet::php::settings::fpm_package
  $php_prefix   = $puphpet::php::settings::prefix
  $php_service  = $puphpet::php::settings::service

  Class['Puphpet::Php::Settings']
  -> Package[$php_package]

  if $php_version == '7.0' {
    class { 'puphpet::php::beta': }
  } else {
    class { 'puphpet::php::repos':
      php_version => $php_version,
    }

    if ! defined(Service[$php_package]) {
      service { $php_package:
        ensure     => 'running',
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        require    => Package[$php_service]
      }
    }

    class { 'php':
      package             => $php_package,
      service             => $php_service,
      version             => 'present',
      service_autorestart => false,
      config_file         => $php_base_ini,
    }
    -> class { 'php::devel': }
  }

  # config file could contain no fpm_ini key
  $php_fpm_inis = array_true($php_values, 'fpm_ini') ? {
    true    => $php_values['fpm_ini'],
    default => { }
  }

  $php_fpm_inis_merged = merge($php_fpm_inis, {
    'pid' => $puphpet::php::settings::pid_file,
  })

  each( $php_fpm_inis_merged ) |$name, $value| {
    puphpet::php::fpm::ini { "${name}: ${value}":
      fpm_version     => $php_version,
      entry           => $name,
      value           => $value,
      php_fpm_service => $php_package
    }
  }

  # config file could contain no fpm_pools key
  $php_fpm_pools = array_true($php_values, 'fpm_pools') ? {
    true    => $php_values['fpm_pools'],
    default => { }
  }

  each( $php_fpm_pools ) |$pKey, $pool_settings| {
    $pool = $php_fpm_pools[$pKey]

    # pool could contain no ini key
    $ini_hash = array_true($pool, 'ini') ? {
      true    => $pool['ini'],
      default => { }
    }

    each( $ini_hash ) |$name, $value| {
      $pool_name = array_true($ini_hash, 'prefix') ? {
        true    => $ini_hash['prefix'],
        default => $pKey
      }

      if $name != 'prefix' {
        puphpet::php::fpm::pool_ini { "${pool_name}/${name}: ${value}":
          fpm_version     => $php_version,
          pool_name       => $pool_name,
          entry           => $name,
          value           => $value,
          php_fpm_service => $php_package
        }
      }
    }
  }

  each( $php_values['modules']['php'] ) |$name| {
    if ! defined(Puphpet::Php::Module[$name]) {
      puphpet::php::module { $name:
        service_autorestart => true,
      }
    }
  }

  each( $php_values['modules']['pear'] ) |$name| {
    if ! defined(Puphpet::Php::Pear[$name]) {
      puphpet::php::pear { $name:
        service_autorestart => true,
      }
    }
  }

  each( $php_values['modules']['pecl'] ) |$name| {
    if ! defined(Puphpet::Php::Extra_repos[$name]) {
      puphpet::php::extra_repos { $name:
        before => Puphpet::Php::Pecl[$name],
      }
    }

    if ! defined(Puphpet::Php::Pecl[$name]) {
      puphpet::php::pecl { $name:
        service_autorestart => true,
      }
    }
  }

  $php_inis = merge({
    'cgi.fix_pathinfo' => 1,
  }, $php_values['ini'])

  each( $php_inis ) |$key, $value| {
    if is_array($value) {
      each( $php_inis[$key] ) |$innerkey, $innervalue| {
        puphpet::php::ini { "${key}_${innerkey}":
          entry       => "CUSTOM_${innerkey}/${key}",
          value       => $innervalue,
          php_version => $php_version,
          webserver   => $php_service
        }
      }
    } else {
      puphpet::php::ini { $key:
        entry       => "CUSTOM/${key}",
        value       => $value,
        php_version => $php_version,
        webserver   => $php_service
      }
    }
  }

  if array_true($php_inis, 'session.save_path') {
    $php_sess_save_path = $php_inis['session.save_path']

    # Handles URLs like tcp://127.0.0.1:6379
    # absolute file paths won't have ":"
    if ! (':' in $php_sess_save_path) and $php_sess_save_path != '/tmp' {
      exec { "mkdir -p ${php_sess_save_path}" :
        creates => $php_sess_save_path,
        notify  => Service[$php_service],
      }

      if ! defined(File[$php_sess_save_path]) {
        file { $php_sess_save_path:
          ensure  => directory,
          owner   => 'www-data',
          group   => 'www-data',
          mode    => '0775',
          require => Exec["mkdir -p ${php_sess_save_path}"],
        }
      }

      exec { 'set php session path owner/group':
        creates => '/.puphpet-stuff/php-session-path-owner-group',
        command => "chown www-data ${php_sess_save_path} && \
                    chgrp www-data ${php_sess_save_path} && \
                    touch /.puphpet-stuff/php-session-path-owner-group",
        require => [
          File[$php_sess_save_path],
          Package[$php_package]
        ],
      }
    }
  }

  if hash_key_equals($php_values, 'composer', 1)
    and ! defined(Class['puphpet::php::composer'])
  {
    class { 'puphpet::php::composer':
      php_package   => $puphpet::php::settings::cli_package,
      composer_home => $php_values['composer_home'],
    }
  }

  # Usually this would go within the library that needs in (Mailcatcher)
  # but the values required are sufficiently complex that it's easier to
  # add here
  if hash_key_equals($mailcatcher_values, 'install', 1)
    and ! defined(Puphpet::Php::Ini['sendmail_path'])
  {
    $mc_from_method = $mailcatcher_values['settings']['from_email_method']
    $mc_path = $mailcatcher_values['settings']['mailcatcher_path']

    $mailcatcher_f_flag = $mc_from_method ? {
      'headers' => '',
      default   => ' -f',
    }

    puphpet::php::ini { 'sendmail_path':
      entry       => 'CUSTOM/sendmail_path',
      value       => "${mc_path}/catchmail${mailcatcher_f_flag}",
      php_version => $php_version,
      webserver   => $php_service
    }
  }
}
