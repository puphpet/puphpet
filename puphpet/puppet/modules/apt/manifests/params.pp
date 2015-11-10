class apt::params {
  $root           = '/etc/apt'
  $provider       = '/usr/bin/apt-get'
  $sources_list_d = "${root}/sources.list.d"
  $apt_conf_d     = "${root}/apt.conf.d"
  $preferences_d  = "${root}/preferences.d"

  case $::lsbdistid {
    'ubuntu', 'debian': {
      $distid = $::lsbdistid
      $distcodename = $::lsbdistcodename
    }
    'linuxmint': {
      if $::lsbdistcodename == 'debian' {
        $distid = 'debian'
        $distcodename = 'wheezy'
      } else {
        $distid = 'ubuntu'
        $distcodename = $::lsbdistcodename ? {
          'qiana'  => 'trusty',
          'petra'  => 'saucy',
          'olivia' => 'raring',
          'nadia'  => 'quantal',
          'maya'   => 'precise',
        }
      }
    }
    'Cumulus Networks': {
      $distid = 'debian'
      $distcodename = $::lsbdistcodename
    }
    '': {
      fail('Unable to determine lsbdistid, is lsb-release installed?')
    }
    default: {
      fail("Unsupported lsbdistid (${::lsbdistid})")
    }
  }
  case $distid {
    'debian': {
      case $distcodename {
        'squeeze': {
          $backports_location = 'http://backports.debian.org/debian-backports'
          $legacy_origin       = true
          $origins             = ['${distro_id} oldstable', #lint:ignore:single_quote_string_with_variables
                                  '${distro_id} ${distro_codename}-security', #lint:ignore:single_quote_string_with_variables
                                  '${distro_id} ${distro_codename}-lts'] #lint:ignore:single_quote_string_with_variables
        }
        'wheezy': {
          $backports_location = 'http://ftp.debian.org/debian/'
          $legacy_origin      = false
          $origins            = ['origin=Debian,archive=stable,label=Debian-Security',
                                  'origin=Debian,archive=oldstable,label=Debian-Security']
        }
        default: {
          $backports_location = 'http://http.debian.net/debian/'
          $legacy_origin      = false
          $origins            = ['origin=Debian,archive=stable,label=Debian-Security']
        }
      }
    }
    'ubuntu': {
      case $distcodename {
        'lucid': {
          $backports_location = 'http://us.archive.ubuntu.com/ubuntu'
          $ppa_options        = undef
          $ppa_package        = 'python-software-properties'
          $legacy_origin      = true
          $origins            = ['${distro_id} ${distro_codename}-security'] #lint:ignore:single_quote_string_with_variables
        }
        'precise': {
          $backports_location = 'http://us.archive.ubuntu.com/ubuntu'
          $ppa_options        = '-y'
          $ppa_package        = 'python-software-properties'
          $legacy_origin      = true
          $origins            = ['${distro_id}:${distro_codename}-security'] #lint:ignore:single_quote_string_with_variables
        }
        'trusty', 'utopic', 'vivid': {
          $backports_location = 'http://us.archive.ubuntu.com/ubuntu'
          $ppa_options        = '-y'
          $ppa_package        = 'software-properties-common'
          $legacy_origin      = true
          $origins            = ['${distro_id}:${distro_codename}-security'] #lint:ignore:single_quote_string_with_variables
        }
        default: {
          $backports_location = 'http://old-releases.ubuntu.com/ubuntu'
          $ppa_options        = '-y'
          $ppa_package        = 'python-software-properties'
          $legacy_origin      = true
          $origins            = ['${distro_id}:${distro_codename}-security'] #lint:ignore:single_quote_string_with_variables
        }
      }
    }
  }
}
