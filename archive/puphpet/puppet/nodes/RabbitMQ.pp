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

  $rabbitmq_settings = merge({'delete_guest_user' => true,}, $rabbitmq_values['settings'])

  create_resources('class', { 'rabbitmq' => $rabbitmq_settings })

  each( $rabbitmq_values['plugins'] ) |$plugin| {
    rabbitmq_plugin { $plugin:
      ensure => present,
    }
  }

  # config file could contain no vhosts key
  $rabbitmq_vhosts = array_true($rabbitmq_values, 'vhosts') ? {
    true    => $rabbitmq_values['vhosts'],
    default => []
  }

  each( $rabbitmq_vhosts ) |$vhost| {
    rabbitmq_vhost { $vhost:
      ensure => present,
    }
  }

  # config file could contain no users key
  $rabbitmq_users = array_true($rabbitmq_values, 'users') ? {
    true    => $rabbitmq_values['users'],
    default => { }
  }

  each( $rabbitmq_users ) |$key, $user| {
    $username = $user['name']
    $is_admin = array_true($user, 'admin') ? {
      true    => true,
      default => false
    }

    # config file could contain no user.permissions
    $permissions = array_true($user, 'permissions') ? {
      true    => $user['permissions'],
      default => { }
    }

    $user_merged = delete(merge($user, {
      'admin' => $is_admin
    }), ['name', 'permissions'])

    create_resources(rabbitmq_user, { "${username}" => $user_merged })

    each($permissions) |$pkey, $permission| {
      $host = $permission['host']
      $permission_merged = delete($permission, 'host')

      create_resources(rabbitmq_user_permissions, {
        "${username}@${host}" => $permission_merged
      })
    }
  }

  if hash_key_equals($php_values, 'install', 1)
    and ! defined(Puphpet::Php::Pecl['amqp'])
  {
    puphpet::php::pecl { 'amqp':
      service_autorestart => $rabbitmq_webserver_restart,
      require             => Package['rabbitmq-server']
    }
  }

  if ! defined(Puphpet::Firewall::Port[$rabbitmq_settings['port']]) {
    puphpet::firewall::port { $rabbitmq_settings['port']: }
  }
}
