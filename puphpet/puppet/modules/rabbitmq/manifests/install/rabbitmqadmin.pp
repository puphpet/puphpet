#
class rabbitmq::install::rabbitmqadmin {

  if($rabbitmq::ssl) {
    $management_port = $rabbitmq::ssl_management_port
  }
  else {
    $management_port = $rabbitmq::management_port
  }

  $default_user = $rabbitmq::default_user
  $default_pass = $rabbitmq::default_pass
  $protocol = $rabbitmq::ssl ? { false => 'http', default => 'https' }

  staging::file { 'rabbitmqadmin':
    target      => "${rabbitmq::rabbitmq_home}/rabbitmqadmin",
    source      => "${protocol}://${default_user}:${default_pass}@localhost:${management_port}/cli/rabbitmqadmin",
    curl_option => '-k --noproxy localhost --retry 30 --retry-delay 6',
    timeout     => '180',
    wget_option => '--no-proxy',
    require     => [
      Class['rabbitmq::service'],
      Rabbitmq_plugin['rabbitmq_management']
    ],
  }

  file { '/usr/local/bin/rabbitmqadmin':
    owner   => 'root',
    group   => '0',
    source  => "${rabbitmq::rabbitmq_home}/rabbitmqadmin",
    mode    => '0755',
    require => Staging::File['rabbitmqadmin'],
  }

}
