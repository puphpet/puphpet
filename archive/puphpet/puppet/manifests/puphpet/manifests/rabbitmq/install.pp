# Class for installing rabbitmq
#
class puphpet::rabbitmq::install {

  if $::operatingsystem == 'debian' {
     fail('RabbitMQ is not supported on Debian. librabbitmq-dev is too old.')
  }

  if $::osfamily == 'redhat' {
    Class['erlang']
    -> Class['rabbitmq']

    include ::erlang
  }

}
