# Class: rabbitmq::config
# Sets all the configuration values for RabbitMQ and creates the directories for
# config and ssl.
class rabbitmq::config {

  $admin_enable               = $rabbitmq::admin_enable
  $cluster_node_type          = $rabbitmq::cluster_node_type
  $cluster_nodes              = $rabbitmq::cluster_nodes
  $config                     = $rabbitmq::config
  $config_cluster             = $rabbitmq::config_cluster
  $config_path                = $rabbitmq::config_path
  $config_stomp               = $rabbitmq::config_stomp
  $default_user               = $rabbitmq::default_user
  $default_pass               = $rabbitmq::default_pass
  $env_config                 = $rabbitmq::env_config
  $env_config_path            = $rabbitmq::env_config_path
  $erlang_cookie              = $rabbitmq::erlang_cookie
  $interface                  = $rabbitmq::interface
  $management_port            = $rabbitmq::management_port
  $node_ip_address            = $rabbitmq::node_ip_address
  $plugin_dir                 = $rabbitmq::plugin_dir
  $rabbitmq_user              = $rabbitmq::rabbitmq_user
  $rabbitmq_group             = $rabbitmq::rabbitmq_group
  $rabbitmq_home              = $rabbitmq::rabbitmq_home
  $port                       = $rabbitmq::port
  $tcp_keepalive              = $rabbitmq::tcp_keepalive
  $service_name               = $rabbitmq::service_name
  $ssl                        = $rabbitmq::ssl
  $ssl_only                   = $rabbitmq::ssl_only
  $ssl_cacert                 = $rabbitmq::ssl_cacert
  $ssl_cert                   = $rabbitmq::ssl_cert
  $ssl_key                    = $rabbitmq::ssl_key
  $ssl_port                   = $rabbitmq::ssl_port
  $ssl_interface              = $rabbitmq::ssl_interface
  $ssl_management_port        = $rabbitmq::ssl_management_port
  $ssl_stomp_port             = $rabbitmq::ssl_stomp_port
  $ssl_verify                 = $rabbitmq::ssl_verify
  $ssl_fail_if_no_peer_cert   = $rabbitmq::ssl_fail_if_no_peer_cert
  $ssl_versions               = $rabbitmq::ssl_versions
  $ssl_ciphers                = $rabbitmq::ssl_ciphers
  $stomp_port                 = $rabbitmq::stomp_port
  $ldap_auth                  = $rabbitmq::ldap_auth
  $ldap_server                = $rabbitmq::ldap_server
  $ldap_user_dn_pattern       = $rabbitmq::ldap_user_dn_pattern
  $ldap_other_bind            = $rabbitmq::ldap_other_bind
  $ldap_use_ssl               = $rabbitmq::ldap_use_ssl
  $ldap_port                  = $rabbitmq::ldap_port
  $ldap_log                   = $rabbitmq::ldap_log
  $ldap_config_variables      = $rabbitmq::ldap_config_variables
  $wipe_db_on_cookie_change   = $rabbitmq::wipe_db_on_cookie_change
  $config_variables           = $rabbitmq::config_variables
  $config_kernel_variables    = $rabbitmq::config_kernel_variables
  $cluster_partition_handling = $rabbitmq::cluster_partition_handling
  $file_limit                 = $rabbitmq::file_limit
  $default_env_variables      =  {
    'NODE_PORT'        => $port,
    'NODE_IP_ADDRESS'  => $node_ip_address
  }

  # Handle env variables.
  $environment_variables = merge($default_env_variables, $rabbitmq::environment_variables)

  file { '/etc/rabbitmq':
    ensure => directory,
    owner  => '0',
    group  => '0',
    mode   => '0644',
  }

  file { '/etc/rabbitmq/ssl':
    ensure => directory,
    owner  => '0',
    group  => '0',
    mode   => '0644',
  }

  file { 'rabbitmq.config':
    ensure  => file,
    path    => $config_path,
    content => template($config),
    owner   => '0',
    group   => '0',
    mode    => '0644',
    notify  => Class['rabbitmq::service'],
  }

  file { 'rabbitmq-env.config':
    ensure  => file,
    path    => $env_config_path,
    content => template($env_config),
    owner   => '0',
    group   => '0',
    mode    => '0644',
    notify  => Class['rabbitmq::service'],
  }

  if $admin_enable {
    file { 'rabbitmqadmin.conf':
      ensure  => file,
      path    => '/etc/rabbitmq/rabbitmqadmin.conf',
      content => template('rabbitmq/rabbitmqadmin.conf.erb'),
      owner   => '0',
      group   => '0',
      mode    => '0644',
      require => File['/etc/rabbitmq'],
    }
  }

  case $::osfamily {
    'Debian': {
      file { '/etc/default/rabbitmq-server':
        ensure  => file,
        content => template('rabbitmq/default.erb'),
        mode    => '0644',
        owner   => '0',
        group   => '0',
        notify  => Class['rabbitmq::service'],
      }
    }
    'RedHat': {
      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        file { '/etc/systemd/system/rabbitmq-server.service.d':
          ensure => directory,
          owner  => '0',
          group  => '0',
          mode   => '0755',
        } ->
        file { '/etc/systemd/system/rabbitmq-server.service.d/limits.conf':
          content => template('rabbitmq/rabbitmq-server.service.d/limits.conf'),
          owner   => '0',
          group   => '0',
          mode    => '0644',
          notify  => Exec['rabbitmq-systemd-reload'],
        }
        exec { 'rabbitmq-systemd-reload':
          command     => '/usr/bin/systemctl daemon-reload',
          notify      => Class['Rabbitmq::Service'],
          refreshonly => true,
        }
      } else {
        file { '/etc/security/limits.d/rabbitmq-server.conf':
          content => template('rabbitmq/limits.conf'),
          owner   => '0',
          group   => '0',
          mode    => '0644',
          notify  => Class['Rabbitmq::Service'],
        }
      }
    }
    default: {
    }
  }

  if $config_cluster {

    if $erlang_cookie == undef {
      fail('You must set the $erlang_cookie value in order to configure clustering.')
    } else {
      rabbitmq_erlang_cookie { "${rabbitmq_home}/.erlang.cookie":
        content        => $erlang_cookie,
        force          => $wipe_db_on_cookie_change,
        rabbitmq_user  => $rabbitmq_user,
        rabbitmq_group => $rabbitmq_group,
        rabbitmq_home  => $rabbitmq_home,
        service_name   => $service_name,
        before         => File['rabbitmq.config'],
        notify         => Class['rabbitmq::service'],
      }
    }
  }
}
