class puphpet::nodejs {

  include ::puphpet::params

  $nodejs = $puphpet::params::hiera['nodejs']

  if $::operatingsystem == 'centos' and $::operatingsystemmajrelease in ['6', 6] {
    fail('Node.js is not supported in CentOS 6')
  }

  class { 'nodejs':
    version      => $nodejs['settings']['version'],
    make_install => false,
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
        require  => Class['nodejs']
      }
    }
  }

}
