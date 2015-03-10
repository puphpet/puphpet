if $php_values == undef { $php_values = hiera_hash('php', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }
if $mailcatcher_values == undef { $mailcatcher_values = hiera_hash('mailcatcher', false) }

include puphpet::params

if hash_key_equals($php_values, 'install', 1) {
  include php::params
  include apache::params
  include nginx::params

  class { 'puphpet::php::repos':
    php_version => $php_values['version']
  }

  Class['Php']
  -> Class['Php::Devel']
  -> Php::Module <| |>
  -> Php::Pear::Module <| |>
  -> Php::Pecl::Module <| |>

  $php_prefix = $::osfamily ? {
    'debian' => 'php5-',
    'redhat' => 'php-',
  }

  $php_fpm_ini = $::osfamily ? {
    'debian' => '/etc/php5/fpm/php.ini',
    'redhat' => '/etc/php.ini',
  }

  if hash_key_equals($apache_values, 'install', 1)
    and hash_key_equals($php_values, 'mod_php', 1)
  {
    $php_package                  = $php::params::package
    $php_webserver_service        = 'httpd'
    $php_webserver_service_ini    = $php_webserver_service
    $php_webserver_service_ensure = 'running'
    $php_webserver_restart        = true
    $php_config_file              = $php::params::config_file
    $php_manage_service           = false
  } elsif hash_key_equals($apache_values, 'install', 1)
    or hash_key_equals($nginx_values, 'install', 1)
  {
    $php_package                  = "${php_prefix}fpm"
    $php_webserver_service        = "${php_prefix}fpm"
    $php_webserver_service_ini    = $php_webserver_service
    $php_webserver_service_ensure = 'running'
    $php_webserver_restart        = true
    $php_config_file              = $php_fpm_ini
    $php_manage_service           = true

    $php_fpm_conf = $puphpet::params::php_fpm_conf

    $php_fpm_perl = 'perl -p -i -e "s#listen = .*#listen = 127.0.0.1:9000#gi"'
    $php_fpm_grep = 'grep -x "listen = 127.0.0.1:9000"'

    exec { 'php_fpm-listen':
      command => "${php_fpm_perl} ${php_fpm_conf}",
      onlyif  => "test -f ${php_fpm_conf}",
      unless  => "${php_fpm_grep} ${php_fpm_conf}",
      path    => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
      require => Package[$php_package],
      notify  => Service[$php_webserver_service],
    }

    $php_fpm_lextensions_perl =
      's#;security.limit_extensions = .*#security.limit_extensions = .php#gi'
    exec { 'php_fpm-security.limit_extensions':
      command => "perl -p -i -e '${php_fpm_lextensions_perl}' ${php_fpm_conf}",
      onlyif  => "test -f ${php_fpm_conf}",
      unless  => "grep -x 'security.limit_extensions = .php' ${php_fpm_conf}",
      path    => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
      require => Package[$php_package],
      notify  => Service[$php_webserver_service],
    }
  } else {
    $php_package                  = "${php_prefix}cli"
    $php_webserver_service        = undef
    $php_webserver_service_ini    = undef
    $php_webserver_service_ensure = undef
    $php_webserver_restart        = false
    $php_config_file              = $php::params::config_file
    $php_manage_service           = false
  }

  class { 'php':
    package             => $php_package,
    service             => $php_webserver_service,
    service_autorestart => false,
    config_file         => $php_config_file,
  }

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

  $php_inis = merge({
    'cgi.fix_pathinfo' => 1,
    'date.timezone'    => $php_values['timezone'],
  }, $php_values['ini'])

  each( $php_inis ) |$key, $value| {
    if is_array($value) {
      each( $php_values['ini'][$key] ) |$innerkey, $innervalue| {
        puphpet::php::ini { "${key}_${innerkey}":
          entry       => "CUSTOM_${innerkey}/${key}",
          value       => $innervalue,
          php_version => $php_values['version'],
          webserver   => $php_webserver_service_ini
        }
      }
    } else {
      puphpet::php::ini { $key:
        entry       => "CUSTOM/${key}",
        value       => $value,
        php_version => $php_values['version'],
        webserver   => $php_webserver_service_ini
      }
    }
  }

  if hash_key_true($php_values['ini'], 'session.save_path'){
    $php_sess_save_path = $php_values['ini']['session.save_path']

    # Handles URLs like tcp://127.0.0.1:6379
    # absolute file paths won't have ":"
    if ! (':' in $php_sess_save_path) {
      exec { "mkdir -p ${php_sess_save_path}" :
        creates => $php_sess_save_path,
        require => Package[$php_package],
        notify  => Service[$php_webserver_service],
      }
      -> exec { "chown -R www-data:www-data ${php_sess_save_path}":
        path => '/bin',
      }
      -> exec { "chmod -R 775 ${php_sess_save_path}":
        path => '/bin',
      }
    }
  }

  if hash_key_equals($php_values, 'composer', 1)
    and ! defined(Class['puphpet::php::composer'])
  {
    class { 'puphpet::php::composer':
      php_package   => "${php::params::module_prefix}cli",
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
      php_version => $php_values['version'],
      webserver   => $php_webserver_service_ini
    }
  }
}
