class puphpet_nodejs (
  $nodejs
) {

  if array_true($nodejs, 'settings')
    and array_true($nodejs['settings'], ['version'])
  {
    $version_num = $nodejs['settings']['version']
  } else {
    $version_num = '0.12'
  }

  if $::osfamily == 'debian' {
    if ! defined(Package['apt-transport-https']) {
      package { 'apt-transport-https':
        ensure => present,
        before => Exec['add nodejs repo']
      }
    }
  }

  $provider = $::osfamily ? {
    'debian' => 'deb',
    default  => 'rpm'
  }

  $version = $version_num ? {
    '5'     => '5.x',
    '4'     => '4.x',
    '0.12'  => '0.12',
    '0.10'  => '0.10',
    default => "${version_num}.x"
  }

  $url = "https://${provider}.nodesource.com/setup_${version}"

  $save_to = '/.puphpet-stuff/nodesource'

  exec { 'add nodejs repo':
    command => "wget --quiet --tries=5 --connect-timeout=10 -O '${save_to}' ${url} \
                && bash ${save_to}",
    creates => $save_to,
    path    => '/usr/bin:/bin',
  }
  -> package { 'nodejs':
    ensure => present,
  }

  each( $nodejs['npm_packages'] ) |$package| {
      $npm_array = split($package, '@')

      if count($npm_array) == 2 {
        $npm_ensure = $npm_array[1]
      } else {
        $npm_ensure = present
      }

    if ! defined(Package[$npm_array[0]]) {
      package { $npm_array[0]:
        ensure   => $npm_ensure,
        provider => npm,
        require  => Package['nodejs']
      }
    }
  }

}
