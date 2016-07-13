class puphpet::rabbitmq::params
  inherits ::puphpet::params
{

  $gpg_key     = '0A9AF2115F4687BD29803A206B73A36E6026DFCA'
  $gpg_key_src = 'https://www.rabbitmq.com/rabbitmq-release-signing-key.asc'

  if array_true($puphpet::params::hiera['apache'], 'install') or
     array_true($puphpet::params::hiera['nginx'], 'install')
  {
    $webserver_restart = true
  } else {
    $webserver_restart = false
  }

  $rabbitmq_dev_pkg = $::osfamily ? {
    'debian' => 'librabbitmq-dev',
    'redhat' => 'librabbitmq-devel',
  }

  $pecl_pkg = 'amqp'

  # config file could contain no plugins key
  $plugins = array_true($puphpet::params::hiera['rabbitmq'], 'plugins') ? {
    true    => $puphpet::params::hiera['rabbitmq']['plugins'],
    default => []
  }

  # config file could contain no vhosts key
  $vhosts = array_true($puphpet::params::hiera['rabbitmq'], 'vhosts') ? {
    true    => $puphpet::params::hiera['rabbitmq']['vhosts'],
    default => []
  }

  # config file could contain no users key
  $users = array_true($puphpet::params::hiera['rabbitmq'], 'users') ? {
    true    => $puphpet::params::hiera['rabbitmq']['users'],
    default => { }
  }

}
