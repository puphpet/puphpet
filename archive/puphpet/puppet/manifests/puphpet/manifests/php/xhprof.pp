class puphpet::php::xhprof (
  $php_version      = '54',
  $webroot_location = '/var/www',
  $webserver_service
) inherits puphpet::params {

  $package_devel = $puphpet::php::settings::package_devel

  exec { 'delete-xhprof-path-if-empty-folder':
    command => "rm -rf ${webroot_location}/xhprof",
    onlyif  => "test ! -f ${webroot_location}/xhprof/extension/config.m4"
  }
  -> vcsrepo { "${webroot_location}/xhprof":
    ensure   => present,
    provider => git,
    source   => 'https://github.com/facebook/xhprof.git',
  }
  -> file { "${webroot_location}/xhprof/xhprof_html":
    ensure  => directory,
    mode    => '0775',
  }
  -> exec { 'configure xhprof':
    cwd     => "${webroot_location}/xhprof/extension",
    command => 'phpize && ./configure && make && make install',
    require => Package[$package_devel],
    path    => [ '/bin/', '/usr/bin/' ]
  }
  -> puphpet::php::ini { 'add xhprof ini extension':
    php_version  => $php_version,
    webserver    => $webserver_service,
    ini_filename => '20-xhprof-custom.ini',
    entry        => 'XHPROF/extension',
    value        => 'xhprof.so',
    ensure       => 'present',
  }
  -> puphpet::php::ini { 'add xhprof ini xhprof.output_dir':
    php_version  => $php_version,
    webserver    => $webserver_service,
    ini_filename => '20-xhprof-custom.ini',
    entry        => 'XHPROF/xhprof.output_dir',
    value        => '/tmp',
    ensure       => 'present',
  }

}
