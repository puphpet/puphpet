class puphpet::nodejs::params
  inherits ::puphpet::params
{

  $provider = $::osfamily ? {
    'debian' => 'deb',
    default  => 'rpm'
  }

  $version = $puphpet::params::hiera['nodejs']['settings']['version'] ? {
    '6'     => '6.x',
    '5'     => '5.x',
    '4'     => '4.x',
    default => '6.x',
  }

  $url = "https://${provider}.nodesource.com/setup_${version}"

  $save_to = '/.puphpet-stuff/nodesource'

  # config file could contain no npm_packages key
  $npm_packages = array_true($puphpet::params::hiera['nodejs'], 'npm_packages') ? {
    true    => $puphpet::params::hiera['nodejs']['npm_packages'],
    default => [ ],
  }

}
