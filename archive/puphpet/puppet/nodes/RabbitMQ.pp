if $rabbitmq_values == undef { $rabbitmq_values = hiera_hash('rabbitmq', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }

include puphpet::params

if hash_key_equals($apache_values, 'install', 1)
  or hash_key_equals($nginx_values, 'install', 1)
{
  $rabbitmq_webserver_restart = true
} else {
  $rabbitmq_webserver_restart = false
}

if hash_key_equals($rabbitmq_values, 'install', 1) {
  if $::osfamily == 'redhat' {
    Class['erlang']
    -> Class['rabbitmq']

    include erlang
  }

  create_resources('class', { 'rabbitmq' => $rabbitmq_values['settings'] })

  if hash_key_equals($php_values, 'install', 1)
    and ! defined(Puphpet::Php::Pecl['amqp'])
  {
    puphpet::php::pecl { 'amqp':
      service_autorestart => $rabbitmq_webserver_restart,
      require             => Package['rabbitmq-server']
    }
  }

  if ! defined(Puphpet::Firewall::Port['15672']) {
    puphpet::firewall::port { '15672': }
  }
}
