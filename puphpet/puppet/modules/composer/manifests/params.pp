# == Class: composer::params
#
# The parameters for the composer class and corresponding definitions
#
# === Authors
#
# Thomas Ploch <profiploch@gmail.com>
# Andrew Johnstone <andrew@ajohnstone.com>
#
# === Copyright
#
# Copyright 2013 Thomas Ploch
#
class composer::params {
  $composer_home = $::composer_home
  $auto_update   = false

  # Support Amazon Linux which is supported by RedHat family
  if $::osfamily == 'Linux' and $::operatingsystem == 'Amazon' {
    $family = 'RedHat'
  } else {
    $family = $::osfamily
  }

  case $family {
    'Debian': {
      $target_dir      = '/usr/local/bin'
      $composer_file   = 'composer'
      $download_method = 'curl'
      $logoutput       = false
      $tmp_path        = '/tmp'
      $php_package     = 'php5-cli'
      $curl_package    = 'curl'
      $wget_package    = 'wget'
      $php_bin         = 'php'
      case $::operatingsystem {
        'Ubuntu': {
          $suhosin_enabled = versioncmp(
            $::operatingsystemmajrelease, '12.04'
          ) <= 0
        }
        default: {
          $suhosin_enabled = true
        }
      }
    }
    'RedHat', 'Centos': {
      $target_dir      = '/usr/local/bin'
      $composer_file   = 'composer'
      $download_method = 'curl'
      $logoutput       = false
      $tmp_path        = '/tmp'
      $php_package     = 'php-cli'
      $curl_package    = 'curl'
      $wget_package    = 'wget'
      $php_bin         = 'php'
      $suhosin_enabled = true
    }
    default: {
      fail("Unsupported platform: ${family}")
    }
  }
}
