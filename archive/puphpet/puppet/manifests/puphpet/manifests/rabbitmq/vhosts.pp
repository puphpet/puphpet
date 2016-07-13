# == Define Resource Type: puphpet::rabbitmq::vhosts
#
define puphpet::rabbitmq::vhosts (
  $vhosts = $::puphpet::rabbitmq::params::vhosts
){

  include ::puphpet::rabbitmq::params

  each( $vhosts ) |$vhost| {
    rabbitmq_vhost { $vhost:
      ensure => present,
    }
  }

}
