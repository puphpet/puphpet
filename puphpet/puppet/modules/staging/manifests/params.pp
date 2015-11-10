# OS specific parameters
class staging::params {
  case $::osfamily {
    default: {
      $path      = '/opt/staging'
      $owner     = '0'
      $group     = '0'
      $mode      = '0755'
      $exec_path = '/usr/local/bin:/usr/bin:/bin'
    }
    'Solaris': {
      $path      = '/opt/staging'
      $owner     = '0'
      $group     = '0'
      $mode      = '0755'
      $exec_path = '/usr/local/bin:/usr/bin:/bin:/usr/sfw/bin'
    }
    'windows': {
      $path      = $::staging_windir
      $owner     = 'S-1-5-32-544' # Adminstrators
      $group     = 'S-1-5-18'     # SYSTEM
      $mode      = '0660'
      $exec_path = $::path
    }
    'FreeBSD': {
      $path      = '/var/tmp/staging'
      $owner     = '0'
      $group     = '0'
      $mode      = '0755'
      $exec_path = '/usr/local/bin:/usr/bin:/bin'
    }
  }
}
