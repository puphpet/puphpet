class puphpet_rabbitmq (
  $rabbitmq,
  $apache,
  $nginx,
  $php
) {

  if $::operatingsystem == 'debian' {
     fail('RabbitMQ is not supported on Debian. librabbitmq-dev is too old.')
  }

  if array_true($apache, 'install') or array_true($nginx, 'install') {
    $webserver_restart = true
  } else {
    $webserver_restart = false
  }

  if $::osfamily == 'redhat' {
    Class['erlang']
    -> Class['rabbitmq']

    include erlang
  }

  $settings = merge({'delete_guest_user' => true,}, $rabbitmq['settings'])

  create_resources('class', { 'rabbitmq' => $settings })

  each( $rabbitmq['plugins'] ) |$plugin| {
    rabbitmq_plugin { $plugin:
      ensure => present,
    }
  }

  # config file could contain no vhosts key
  $vhosts = array_true($rabbitmq, 'vhosts') ? {
    true    => $rabbitmq['vhosts'],
    default => []
  }

  each( $vhosts ) |$vhost| {
    rabbitmq_vhost { $vhost:
      ensure => present,
    }
  }

  # config file could contain no users key
  $users = array_true($rabbitmq, 'users') ? {
    true    => $rabbitmq['users'],
    default => { }
  }

  each( $users ) |$key, $user| {
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

    $merged = delete(merge($user, {
      'admin' => $is_admin
    }), ['name', 'permissions'])

    create_resources(rabbitmq_user, { "${username}" => $merged })

    each($permissions) |$pkey, $permission| {
      $host = $permission['host']
      $permission_merged = delete($permission, 'host')

      create_resources(rabbitmq_user_permissions, {
        "${username}@${host}" => $permission_merged
      })
    }
  }

  if array_true($php, 'install') and ! defined(Puphpet::Php::Pecl['amqp']) {
    $rabbitmq_dev_pkg = $::osfamily ? {
      'debian' => 'librabbitmq-dev',
      'redhat' => 'librabbitmq-devel',
    }

    if ! defined(Package[$rabbitmq_dev_pkg]) {
      package { $rabbitmq_dev_pkg:
        ensure => present,
      }
    }

    $pecl_pkg = 'amqp'

    puphpet::php::pecl { $pecl_pkg:
      service_autorestart => $webserver_restart,
      require             => [
        Package['rabbitmq-server'],
        Package[$rabbitmq_dev_pkg],
      ]
    }
  }

  if ! defined(Puphpet::Firewall::Port["${settings['port']}"]) {
    puphpet::firewall::port { "${settings['port']}": }
  }

}
