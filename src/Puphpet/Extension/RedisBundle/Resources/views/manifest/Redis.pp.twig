if $redis_values == undef { $redis_values = hiera_hash('redis', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }

include puphpet::params

if hash_key_equals($apache_values, 'install', 1)
  or hash_key_equals($nginx_values, 'install', 1)
{
  $redis_webserver_restart = true
} else {
  $redis_webserver_restart = false
}

if hash_key_equals($redis_values, 'install', 1) {
  create_resources('class', { 'redis' => $redis_values['settings'] })

  if hash_key_equals($php_values, 'install', 1)
    and ! defined(Puphpet::Php::Pecl['redis'])
  {
    puphpet::php::pecl { 'redis':
      service_autorestart => $redis_webserver_restart,
      require             => Class['redis']
    }
  }
}
