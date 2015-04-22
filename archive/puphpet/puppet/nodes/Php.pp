if $php_values == undef { $php_values = hiera_hash('php', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }
if $mailcatcher_values == undef { $mailcatcher_values = hiera_hash('mailcatcher', false) }

include puphpet::params

if array_true($php_values, 'install') {
  include ::apache::params
  include ::nginx::params


  Class['Puphpet::Php::Settings']
  -> Puphpet::Php::Module <| |>
  -> Puphpet::Php::Pear <| |>
  -> Puphpet::Php::Pecl <| |>
  -> Class['Puphpet::Php::Xdebug']

  $php_fcgi = array_true($apache_values, 'install')
           or array_true($nginx_values, 'install')

  $php_version_tmp = $php_values['settings']['version']

  class { 'puphpet::php::settings':
    version => $php_version_tmp,
  }

  if $php_version_tmp == '7.0' or $php_version_tmp == '70' {
    $php_version = '7.0'

    class { 'puphpet::php::beta': }
  } else {
    include ::php::params

    $php_version = $php_version_tmp

    class { 'puphpet::php::repos':
      php_version => $php_version
    }

    Class['Php']
    -> Class['Php::Devel']
    -> Php::Module <| |>
    -> Php::Pear::Module <| |>
    -> Php::Pecl::Module <| |>
  }

  $php_prefix        = $puphpet::php::settings::php_prefix
  $php_fpm_ini       = $puphpet::php::settings::php_fpm_ini
  $config_file       = $puphpet::php::settings::config_file
  $php_module_prefix = $puphpet::php::settings::php_module_prefix

  if $php_fcgi {
    $php_package                  = "${php_prefix}fpm"
    $php_webserver_service        = "${php_prefix}fpm"
    $php_webserver_service_ini    = $php_webserver_service
    $php_webserver_service_ensure = 'running'
    $php_webserver_service_notify = [Service[$php_webserver_service]]
    $php_webserver_restart        = true
    $php_config_file              = $php_fpm_ini
    $php_manage_service           = true

    # config file could contain no fpm_ini key
    $php_fpm_inis = array_true($php_values, 'fpm_ini') ? {
      true    => $php_values['fpm_ini'],
      default => { }
    }

    each( $php_fpm_inis ) |$name, $value| {
      puphpet::php::fpm::ini { "${name}: ${value}":
        fpm_version     => $php_version,
        entry           => $name,
        value           => $value,
        php_fpm_service => $php_webserver_service
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
            php_fpm_service => $php_webserver_service
          }
        }
      }
    }
  } else {
    $php_package                  = "${php_prefix}cli"
    $php_webserver_service        = undef
    $php_webserver_service_ini    = undef
    $php_webserver_service_ensure = undef
    $php_webserver_service_notify = []
    $php_webserver_restart        = false
    $php_config_file              = $config_file
    $php_manage_service           = false
  }

  if $php_version != '7.0' {
    if $php_manage_service
      and $php_webserver_service
      and ! defined(Service[$php_webserver_service])
    {
      service { $php_webserver_service:
        ensure     => $php_webserver_service_ensure,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        require    => Package[$php_webserver_service]
      }
    }

    class { 'php':
      package             => $php_package,
      service             => $php_webserver_service,
      version             => 'present',
      service_autorestart => false,
      config_file         => $php_config_file,
    }

    class { 'php::devel': }

    each( $php_values['modules']['php'] ) |$name| {
      if ! defined(Puphpet::Php::Module[$name]) {
        puphpet::php::module { $name:
          service_autorestart => $php_webserver_restart,
        }
      }
    }

    each( $php_values['modules']['pear'] ) |$name| {
      if ! defined(Puphpet::Php::Pear[$name]) {
        puphpet::php::pear { $name:
          service_autorestart => $php_webserver_restart,
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
          service_autorestart => $php_webserver_restart,
        }
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
          webserver   => $php_webserver_service_ini
        }
      }
    } else {
      puphpet::php::ini { $key:
        entry       => "CUSTOM/${key}",
        value       => $value,
        php_version => $php_version,
        webserver   => $php_webserver_service_ini
      }
    }
  }

  if array_true($php_inis, 'session.save_path') {
    $php_sess_save_path = $php_inis['session.save_path']

    # Handles URLs like tcp://127.0.0.1:6379
    # absolute file paths won't have ":"
    if ! (':' in $php_sess_save_path) {
      exec { "mkdir -p ${php_sess_save_path}" :
        creates => $php_sess_save_path,
        notify  => $php_webserver_service_notify,
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
    }
  }

  if hash_key_equals($php_values, 'composer', 1)
    and ! defined(Class['puphpet::php::composer'])
  {
    class { 'puphpet::php::composer':
      php_package   => "${php_module_prefix}cli",
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
      webserver   => $php_webserver_service_ini
    }
  }
}
