# == Define Resource Type: puphpet::rabbitmq::plugins
#
define puphpet::rabbitmq::plugins (
  $plugins = $::puphpet::rabbitmq::params::plugins
){

  include ::puphpet::rabbitmq::params

  each( $plugins ) |$plugin| {
    rabbitmq_plugin { $plugin:
      ensure => present,
    }
  }

}
