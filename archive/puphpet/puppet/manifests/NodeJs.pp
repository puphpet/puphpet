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
    if ! defined('apt-transport-https') {
      package { 'apt-transport-https':
        ensure => present
      }
    }

    $version = $version_num ? {
      '5'     => '5.x',
      '4'     => '4.x',
      '0.12'  => '0.12',
      '0.10'  => '0.10',
      default => "${version_num}.x"
    }

    $url = "https://deb.nodesource.com/setup_${version}"

    $save_to = '/.puphpet-stuff/nodesource'

    exec { 'add nodejs repo':
      command => "wget --quiet --tries=5 --connect-timeout=10 -O '${save_to}' ${url} \
                  && bash ${save_to}",
      creates => $save_to,
      path    => '/usr/bin:/bin',
      require => Package['apt-transport-https'],
    }
    -> package { 'nodejs':
      ensure => present,
    }
  } else {
    $pkg_url = $version_num ? {
      '0.12'  => 'https://rpm.nodesource.com/pub_0.12/el/6/x86_64/nodejs-0.12.9-1nodesource.el6.x86_64.rpm',
      '0.10'  => 'https://rpm.nodesource.com/pub_0.10/el/6/x86_64/nodejs-0.10.41-1nodesource.el6.x86_64.rpm',
      default => false
    }

    if ! $pkg_url {
      fail('You have chosen an unsupported NodeJS version.')
    }

    $dev_url = $version_num ? {
      '0.12' => 'https://rpm.nodesource.com/pub_0.12/el/6/x86_64/nodejs-devel-0.12.9-1nodesource.el6.x86_64.rpm',
      '0.10' => 'https://rpm.nodesource.com/pub_0.10/el/6/x86_64/nodejs-devel-0.10.41-1nodesource.el6.x86_64.rpm',
    }

    $pkg_save_to = '/.puphpet-stuff/nodesource_pkg'
    $dev_save_to = '/.puphpet-stuff/nodesource_dev'

    exec { 'add nodejs rpm':
      command => "wget --quiet --tries=5 --connect-timeout=10 -O '${pkg_save_to}' ${pkg_url}",
      creates => $pkg_save_to,
      path    => '/usr/bin:/bin',
    }
    -> exec { 'add nodejs dev rpm':
      command => "wget --quiet --tries=5 --connect-timeout=10 -O '${dev_save_to}' ${dev_url}",
      creates => $dev_save_to,
      path    => '/usr/bin:/bin',
    }
    -> package { 'nodejs':
      ensure   => 'present',
      provider => 'rpm',
      source   => $pkg_save_to,
    }
    -> package { 'nodejs-devel':
      ensure   => 'present',
      provider => 'rpm',
      source   => $dev_save_to,
    }
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
