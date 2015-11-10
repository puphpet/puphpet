# Class: apache::version
#
# Try to automatically detect the version by OS
#
class apache::version {
  # This will be 5 or 6 on RedHat, 6 or wheezy on Debian, 12 or quantal on Ubuntu, 3 on Amazon, etc.
  $osr_array = split($::operatingsystemrelease,'[\/\.]')
  $distrelease = $osr_array[0]
  if ! $distrelease {
    fail("Class['apache::version']: Unparsable \$::operatingsystemrelease: ${::operatingsystemrelease}")
  }

  case $::osfamily {
    'RedHat': {
      if ($::operatingsystem == 'Fedora' and versioncmp($distrelease, '18') >= 0) or ($::operatingsystem != 'Fedora' and versioncmp($distrelease, '7') >= 0) {
        $default = '2.4'
      } else {
        $default = '2.2'
      }
    }
    'Debian': {
      if $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '13.10') >= 0 {
        $default = '2.4'
      } elsif $::operatingsystem == 'Debian' and versioncmp($distrelease, '8') >= 0 {
        $default = '2.4'
      } else {
        $default = '2.2'
      }
    }
    'FreeBSD': {
      $default = '2.4'
    }
    'Gentoo': {
      $default = '2.4'
    }
    default: {
      fail("Class['apache::version']: Unsupported osfamily: ${::osfamily}")
    }
  }
}
