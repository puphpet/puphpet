# Class for installing rabbitmq
#
class puphpet::rabbitmq::install
  inherits puphpet::rabbitmq::params
{

  $rabbitmq = $puphpet::params::hiera['rabbitmq']
  $php      = $puphpet::params::hiera['php']

  if $::operatingsystem == 'debian' {
     fail('RabbitMQ is not supported on Debian. librabbitmq-dev is too old.')
  }

  if $::osfamily == 'redhat' {
    Class['erlang']
    -> Class['rabbitmq']

    include ::erlang
  }

  $settings = merge({
    'delete_guest_user' => true,
    'manage_repos'      => false,
  }, $rabbitmq['settings'])

  create_resources('class', { 'rabbitmq' => $settings })

  include ::puphpet::rabbitmq::repos

  puphpet::rabbitmq::plugins { 'from puphpet::rabbitmq::install': }
  puphpet::rabbitmq::vhosts { 'from puphpet::rabbitmq::install': }
  puphpet::rabbitmq::users { 'from puphpet::rabbitmq::install': }

  if array_true($php, 'install') and ! defined(Puphpet::Php::Pecl['amqp']) {
    if ! defined(Package[$puphpet::rabbitmq::params::rabbitmq_dev_pkg]) {
      package { $puphpet::rabbitmq::params::rabbitmq_dev_pkg:
        ensure => present,
      }
    }

    puphpet::php::pecl { $puphpet::rabbitmq::params::pecl_pkg:
      service_autorestart => $puphpet::rabbitmq::params::webserver_restart,
      require             => [
        Package['rabbitmq-server'],
        Package[$puphpet::rabbitmq::params::rabbitmq_dev_pkg],
      ]
    }
  }

  if ! defined(Puphpet::Firewall::Port["${settings['port']}"]) {
    puphpet::firewall::port { "${settings['port']}": }
  }

}
