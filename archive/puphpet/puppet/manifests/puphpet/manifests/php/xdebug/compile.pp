class puphpet::php::xdebug::compile
 inherits puphpet::php::xdebug::params {

  include puphpet::php::settings

  vcsrepo { '/.puphpet-stuff/xdebug':
    ensure   => present,
    provider => git,
    source   => $puphpet::php::xdebug::params::git_source,
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
    webserver   => $puphpet::php::settings::service,
    require     => Exec['copy xdebug.so to modules dir'],
  }

}
