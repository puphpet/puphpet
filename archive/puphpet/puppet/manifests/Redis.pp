class puphpet_redis (
  $redis,
  $apache,
  $nginx,
  $php
) {

  if array_true($apache, 'install') or array_true($nginx, 'install') {
    $webserver_restart = true
  } else {
    $webserver_restart = false
  }

  create_resources('class', { 'redis' => $redis['settings'] })

  if array_true($php, 'install') and ! defined(Puphpet::Php::Pecl['redis']) {
    puphpet::php::pecl { 'redis':
      service_autorestart => $webserver_restart,
      require             => Class['redis']
    }
  }

}
