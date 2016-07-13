class puphpet::nodejs::install
  inherits puphpet::nodejs::params
{

  $nodejs = $puphpet::params::hiera['nodejs']

  if $::osfamily == 'debian' and
    ! defined(Package['apt-transport-https'])
  {
    package { 'apt-transport-https':
      before => Exec['add nodejs repo']
    }
  }

  puphpet::server::wget { $puphpet::nodejs::params::save_to:
    source => $puphpet::nodejs::params::url,
    user   => 'root',
    group  => 'root',
    mode   => 'a+x'
  }
  -> exec { 'add nodejs repo':
    command     => $puphpet::nodejs::params::save_to,
    subscribe   => File[$puphpet::nodejs::params::save_to],
    refreshonly => true,
    path        => [ '/bin', '/sbin/', '/usr/sbin/', '/usr/bin/' ],
  }
  -> package { 'nodejs':
    ensure => present,
  }

  puphpet::nodejs::npm_packages { 'from puphpet::nodejs::install': }

}
