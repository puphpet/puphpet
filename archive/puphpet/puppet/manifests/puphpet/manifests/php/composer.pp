class puphpet::php::composer (
  $php_package,
  $composer_home = false
){

  $composer_home_real = $composer_home ? {
    false   => false,
    undef   => false,
    ''      => false,
    default => $composer_home,
  }

  if $composer_home_real {
    file { $composer_home_real:
      ensure  => directory,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0775',
      require => [
        Group['www-data'],
        Group['www-user']
      ],
    }

    file_line { "COMPOSER_HOME=${composer_home_real}":
      path => '/etc/environment',
      line => "COMPOSER_HOME=${composer_home_real}",
    }
  }

  class { '::composer':
    target_dir      => '/usr/local/bin',
    composer_file   => 'composer',
    download_method => 'wget',
    logoutput       => false,
    tmp_path        => '/tmp',
    php_package     => $php_package,
    suhosin_enabled => false,
  }

}
