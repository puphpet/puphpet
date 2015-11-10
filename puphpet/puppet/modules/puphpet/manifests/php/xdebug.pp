class puphpet::php::xdebug (
  $install_cli = true,
  $webserver,
  $compile     = false,
  $ensure      = present
) inherits puphpet::params {

  if $webserver != undef {
    $notify_service = Service[$webserver]
  } else {
    $notify_service = []
  }

  if !$compile and ! defined(Package[$puphpet::params::xdebug_package])
    and $puphpet::php::settings::enable_xdebug
  {
    package { 'xdebug':
      name    => $puphpet::params::xdebug_package,
      ensure  => installed,
      require => Package['php'],
      notify  => $notify_service,
    }
  } elsif $puphpet::php::settings::enable_xdebug {
    # php 5.6 requires xdebug be compiled, for now
    case $::operatingsystem {
      # Debian and Ubuntu slightly differ
      'debian', 'ubuntu': {
        if is_dir('/usr/lib/php5/20131226-zts') {
          $mod_dir = '/usr/lib/php5/20131226-zts'
        } else {
          $mod_dir = '/usr/lib/php5/20131226'
        }
      }
      'redhat', 'centos': {$mod_dir = '/usr/lib64/php/modules'}
    }

    vcsrepo { '/.puphpet-stuff/xdebug':
      ensure   => present,
      provider => git,
      source   => 'https://github.com/xdebug/xdebug.git',
      revision => 'XDEBUG_2_3_1',
      require  => Class['Php::Devel']
    }
    -> exec { 'phpize && ./configure --enable-xdebug && make':
      creates => '/.puphpet-stuff/xdebug/configure',
      cwd     => '/.puphpet-stuff/xdebug',
    }
    -> exec { "cp /.puphpet-stuff/xdebug/modules/xdebug.so ${mod_dir}/xdebug.so":
      creates => "${mod_dir}/xdebug.so",
    }

    puphpet::php::ini { 'xdebug/zend_extension':
      entry       => "XDEBUG/zend_extension",
      value       => "${mod_dir}/xdebug.so",
      php_version => '5.6',
      webserver   => $webserver,
      require     => Exec["cp /.puphpet-stuff/xdebug/modules/xdebug.so ${mod_dir}/xdebug.so"],
    }
  }

  # shortcut for xdebug CLI debugging
  if $install_cli and defined(File['/usr/bin/xdebug']) == false
    and $puphpet::php::settings::enable_xdebug
  {
    file { '/usr/bin/xdebug':
      ensure  => present,
      mode    => '+X',
      source  => 'puppet:///modules/puphpet/xdebug_cli_alias.erb',
      require => Package['php']
    }
  }

}
