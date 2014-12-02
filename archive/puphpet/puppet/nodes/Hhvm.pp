if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }

include puphpet::params
include puphpet::supervisord

if hash_key_equals($hhvm_values, 'install', 1) {
  if hash_key_equals($apache_values, 'install', 1) {
    $hhvm_webserver         = 'httpd'
    $hhvm_webserver_restart = true
  } elsif hash_key_equals($nginx_values, 'install', 1) {
    $hhvm_webserver         = 'nginx'
    $hhvm_webserver_restart = true
  } else {
    $hhvm_webserver         = undef
    $hhvm_webserver_restart = true
  }

  class { 'puphpet::hhvm':
    nightly   => $hhvm_values['nightly'],
    webserver => $hhvm_webserver
  }

  if ! defined(User['hhvm']) {
    user { 'hhvm':
      home       => '/home/hhvm',
      groups     => 'www-data',
      ensure     => present,
      managehome => true,
      require    => Group['www-data']
    }
  }

  $supervisord_hhvm_cmd = "hhvm --mode server -vServer.Type=fastcgi -vServer.Port=${hhvm_values['settings']['port']}"

  supervisord::program { 'hhvm':
    command     => $supervisord_hhvm_cmd,
    priority    => '100',
    user        => 'hhvm',
    autostart   => true,
    autorestart => 'true',
    environment => { 'PATH' => '/bin:/sbin:/usr/bin:/usr/sbin' },
    require     => [
      User['hhvm'],
      Package['hhvm']
    ]
  }

  file { '/usr/bin/php':
    ensure  => 'link',
    target  => '/usr/bin/hhvm',
    require => Package['hhvm']
  }

  if count($hhvm_values['ini']) > 0 {
    $hhvm_inis = merge({
      'date.timezone' => $hhvm_values['timezone'],
    }, $hhvm_values['ini'])

    $hhvm_ini = '/etc/hhvm/php.ini'

    each( $hhvm_inis ) |$key, $value| {
      exec { "hhvm-php.ini@${key}/${value}":
        command => "perl -p -i -e 's#${key} = .*#${key} = ${value}#gi' ${hhvm_ini}",
        onlyif  => "test -f ${hhvm_ini}",
        unless  => "grep -x '${key} = ${value}' ${hhvm_ini}",
        path    => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
        require => Package['hhvm'],
        notify  => Supervisord::Supervisorctl['restart_hhvm'],
      }
    }

    supervisord::supervisorctl { 'restart_hhvm':
      command     => 'restart',
      process     => 'hhvm',
      refreshonly => true,
    }
  }

  if hash_key_equals($hhvm_values, 'composer', 1)
    and ! defined(Class['puphpet::php::composer'])
  {
    class { 'puphpet::php::composer':
      php_package   => 'hhvm',
      composer_home => $hhvm_values['composer_home'],
    }
  }
}
