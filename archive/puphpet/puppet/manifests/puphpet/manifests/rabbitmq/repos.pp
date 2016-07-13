class puphpet::rabbitmq::repos {

  include ::puphpet::rabbitmq::params

  case $::osfamily {
    'RedHat', 'SUSE': {
      Class['::puphpet::rabbitmq::repos']
      -> Package <| title == 'rabbitmq-server' |>

      exec { "rpm --import ${puphpet::rabbitmq::params::gpg_key_src}":
        path   => ['/bin','/usr/bin','/sbin','/usr/sbin'],
        unless => 'rpm -q gpg-pubkey-6026dfca-573adfde 2>/dev/null',
      }
    }
    'Debian': {
      class { '::rabbitmq::repo::apt' :
        key        => $puphpet::rabbitmq::params::gpg_key,
        key_source => $puphpet::rabbitmq::params::gpg_key_src,
      }
    }
  }

}
