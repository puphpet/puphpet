# Class for installing mailhog smtp server
#
#  [*install_path*]
#    Path to install bin
#
class puphpet::mailhog::install (
  $install_path = $puphpet::mailhog::params::install_path
) inherits puphpet::mailhog::params {

  group { $puphpet::mailhog::params::group:
    ensure => present,
  }

  user { $puphpet::mailhog::params::user:
    ensure     => present,
    groups     => [$puphpet::mailhog::params::group],
    managehome => false,
    shell      => '/bin/bash',
    require    => Group[$puphpet::mailhog::params::group],
  }

  wget::fetch { $puphpet::mailhog::params::download_url:
    cache_dir   => '/var/cache/wget',
    destination => $install_path,
    timeout     => 0,
    verbose     => false,
    mode        => '+x',
  }

}
