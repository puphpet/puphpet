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

  if array_true($redis['settings'], 'conf_port') {
    $port = $redis['settings']['conf_port']
  } else {
    $port = $redis['settings']['port']
  }

  $settings = delete(deep_merge({
    'port' => $port,
  }, $redis['settings']), 'conf_port')

  create_resources('class', { 'redis' => $settings })

  if array_true($php, 'install') and ! defined(Puphpet::Php::Pecl['redis']) {
    puphpet::php::pecl { 'redis':
      service_autorestart => $webserver_restart,
      require             => Class['redis']
    }
  }

}
