# ppa.pp

define apt::ppa(
  $ensure         = 'present',
  $release        = $::lsbdistcodename,
  $options        = $::apt::params::ppa_options,
  $package_name   = $::apt::params::ppa_package,
  $package_manage = true,
) {
  include apt::params
  include apt::update

  $sources_list_d = $apt::params::sources_list_d

  if ! $release {
    fail('lsbdistcodename fact not available: release parameter required')
  }

  if $::operatingsystem != 'Ubuntu' {
    fail('apt::ppa is currently supported on Ubuntu only.')
  }

  $filename_without_slashes = regsubst($name, '/', '-', 'G')
  $filename_without_dots    = regsubst($filename_without_slashes, '\.', '_', 'G')
  $filename_without_ppa     = regsubst($filename_without_dots, '^ppa:', '', 'G')
  $sources_list_d_filename  = "${filename_without_ppa}-${release}.list"

  if $ensure == 'present' {
    if $package_manage {
      if ! defined(Package[$package_name]) {
        package { $package_name: }
      }

      $_require = [File['sources.list.d'], Package[$package_name]]
    } else {
      $_require = File['sources.list.d']
    }

    if defined(Class['apt']) {
      case $::apt::proxy_host {
        false, '', undef: {
          $proxy_env = []
        }
        default: {
          $proxy_env = ["http_proxy=http://${::apt::proxy_host}:${::apt::proxy_port}", "https_proxy=http://${::apt::proxy_host}:${::apt::proxy_port}"]
        }
      }
    } else {
      $proxy_env = []
    }

    exec { "add-apt-repository-${name}":
      environment => $proxy_env,
      command     => "/usr/bin/add-apt-repository ${options} ${name}",
      unless      => "/usr/bin/test -s ${sources_list_d}/${sources_list_d_filename}",
      user        => 'root',
      logoutput   => 'on_failure',
      notify      => Exec['apt_update'],
      require     => $_require,
    }

    file { "${sources_list_d}/${sources_list_d_filename}":
      ensure  => file,
      require => Exec["add-apt-repository-${name}"],
    }
  }
  else {
    file { "${sources_list_d}/${sources_list_d_filename}":
      ensure => 'absent',
      notify => Exec['apt_update'],
    }
  }

  # Need anchor to provide containment for dependencies.
  anchor { "apt::ppa::${name}":
    require => Class['apt::update'],
  }
}
