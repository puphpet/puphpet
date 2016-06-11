class puphpet::php::xdebug (
  $install_cli = true,
  $webserver,
  $compile     = false,
  $ensure      = present,
  $php_package = $puphpet::php::settings::fpm_package
) inherits puphpet::params {

  if $webserver != undef {
    $notify_service = Service[$webserver]
  } else {
    $notify_service = []
  }

  $xdebug_package = $::osfamily ? {
    'Debian' => "${puphpet::php::settings::prefix}xdebug",
    'Redhat' => "${puphpet::php::settings::pecl_prefix}xdebug"
  }

  if !$compile and ! defined(Package[$xdebug_package])
    and $puphpet::php::settings::enable_xdebug
  {
    package { 'xdebug':
      name    => $xdebug_package,
      ensure  => installed,
      require => Package[$php_package],
      notify  => $notify_service,
    }
  } elsif $puphpet::php::settings::enable_xdebug {
    # php 5.6 requires xdebug be compiled, for now
    vcsrepo { '/.puphpet-stuff/xdebug':
      ensure   => present,
      provider => git,
      source   => 'https://github.com/xdebug/xdebug.git',
      require  => Package[$puphpet::php::settings::package_devel]
    }
    -> exec { 'phpize && ./configure --enable-xdebug && make':
      creates => '/.puphpet-stuff/xdebug/configure',
      cwd     => '/.puphpet-stuff/xdebug',
    }
    -> exec { 'copy xdebug.so to modules dir':
      command => "cp /.puphpet-stuff/xdebug/modules/xdebug.so `php-config --extension-dir`/xdebug.so \
                  && touch /.puphpet-stuff/xdebug-installed",
      creates => '/.puphpet-stuff/xdebug-installed',
    }

    puphpet::php::ini { 'xdebug/zend_extension':
      entry       => "XDEBUG/zend_extension",
      value       => 'xdebug.so',
      php_version => $puphpet::php::settings::version,
      webserver   => $webserver,
      require     => Exec['copy xdebug.so to modules dir'],
    }
  }

  # shortcut for xdebug CLI debugging
  if $install_cli and defined(File['/usr/bin/xdebug']) == false
    and $puphpet::php::settings::enable_xdebug
  {
    file { '/usr/bin/xdebug':
      ensure  => present,
      mode    => '+x',
      source  => 'puppet:///modules/puphpet/xdebug_cli_alias.erb',
      require => Package[$php_package]
    }
  }

}
