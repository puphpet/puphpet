# Downloads and sets up PHP7 from zend's nightly archive

class puphpet::php::beta {

  $url = $::osfamily ? {
    'debian' => 'http://repo.puphpet.com/php7/php-7.0-latest-DEB-x86_64.tar.gz',
    'redhat' => 'http://repo.puphpet.com/php7/php-7.0-latest-RHEL-x86_64.tar.gz',
  }

  $packages = $::osfamily ? {
    'debian' => ['libcurl4-openssl-dev', 'libmcrypt-dev', 'libxml2-dev', 'libjpeg-dev',
                 'libfreetype6-dev', 'libmysqlclient-dev', 'libt1-dev', 'libgmp-dev',
                 'libpspell-dev', 'libicu-dev', 'librecode-dev'],
    'redhat' => ['recode-devel', 'aspell-devel', 'libmcrypt-devel', 't1lib-devel',
                 'libXpm-devel', 'libpng-devel', 'libjpeg-turbo-devel', 'bzip2-devel',
                 'openssl-libs', 'libicu-devel']
  }

  each( $packages ) |$package| {
    if ! defined(Package[$package]) {
      package { $package:
        ensure => present,
      }
    }
  }

  $save_to    = '/.puphpet-stuff/php-7.0-latest.tar.gz'
  $extract_to = '/.puphpet-stuff/php-7.0-latest'

  $cmd = "wget --quiet --tries=5 --connect-timeout=10 -O '${save_to}' ${url}"

  exec { "download ${url}":
    creates => $save_to,
    command => $cmd,
    timeout => 3600,
    path    => '/usr/bin',
  }
  -> exec { "untar ${save_to}":
    creates => $extract_to,
    command => "mkdir -p ${extract_to} && \
                tar xzf '${save_to}' -C ${extract_to} --strip-components=1",
    cwd     => '/.puphpet-stuff',
    path    => '/bin',
  }

  file { ['/usr/local/php7', '/usr/local/php7/bin']:
    ensure  => directory,
    require => Exec["untar ${save_to}"],
  }

  $bin_files = {
    'phar.phar'  => 'phar7.phar',
    'php'        => 'php7',
    'php-cgi'    => 'php7-cgi',
    'php-config' => 'php7-config',
    'phpize'     => 'phpize7'
  }

  each( $bin_files ) |$file, $symlink| {
    $path        = "/usr/bin/${file}"
    $symlinkPath = "/usr/bin/${symlink}"
    $source      = "${extract_to}/local/php7/bin/${file}"

    file { $path:
      ensure  => present,
      source  => $source,
      require => File['/usr/local/php7/bin']
    }
    -> file { $symlinkPath:
      ensure => link,
      target => $path,
    }
    -> file { "/usr/local/php7/bin/${file}":
      ensure => link,
      target => $path,
    }
  }

  file { '/usr/bin/phar':
    ensure  => link,
    target  => '/usr/bin/phar.phar',
    require => File['/usr/bin/phar.phar'],
  }

  file { '/usr/sbin/php-fpm':
    ensure  => present,
    source  => "${extract_to}/local/php7/sbin/php-fpm",
    require => Exec["untar ${save_to}"]
  }
  -> file { '/usr/sbin/php7-fpm':
    ensure  => link,
    target  => '/usr/sbin/php-fpm',
  }

  file { ['/etc/php7', '/etc/php7/mods-available',
          '/etc/php7/cli',
          '/etc/php7/fpm', '/etc/php7/fpm/pool.d']:
    ensure => directory,
  }
  -> file { ['/etc/php7/cli/conf.d', '/etc/php7/fpm/conf.d']:
    ensure => link,
    target => '/etc/php7/mods-available'
  }
  -> file { '/usr/local/php7/etc':
    ensure => link,
    target => '/etc/php7/cli'
  }
  -> file { '/etc/php7/fpm/php-fpm.conf':
    ensure => present,
    source => "puppet:///modules/puphpet/php7/php-fpm.conf",
    owner  => 'root',
    group  => 'root',
  }
  -> file { '/etc/php7/fpm/pool.d/www.conf':
    ensure => present,
    source => "puppet:///modules/puphpet/php7/www.conf",
    owner  => 'root',
    group  => 'root',
  }
  -> file { '/usr/lib/php7':
    ensure => directory,
  }
  -> file { '/usr/lib/php7/php7-fpm-checkconf':
    ensure => present,
    source => 'puppet:///modules/puphpet/php7/php7-fpm-checkconf',
    mode   => '0764',
    owner  => 'root',
    group  => 'root',
  }
  -> file { '/etc/init.d/php7-fpm':
    ensure => present,
    source => 'puppet:///modules/puphpet/php7/php7-fpm',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
  # ensure as absent because these are not true packages
  -> package { ['php7-cli', 'php7-fpm']:
    ensure  => absent,
    require => Package[$packages],
  }
  -> service { 'php7-fpm':
    ensure     => running,
    hasrestart => false,
    hasstatus  => true,
    path       => '/etc/init.d/',
    provider   => 'init',
    require    => [
      File['/etc/init.d/php7-fpm'],
      Package[$packages],
    ]
  }

}
