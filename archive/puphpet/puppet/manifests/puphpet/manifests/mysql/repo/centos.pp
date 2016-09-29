class puphpet::mysql::repo::centos (
  $version = $::puphpet::mysql::params::version
) {

  if $version in ['55', '5.5'] {
    class { 'yum::repo::mysql_community':
      enabled_version => '5.5',
    }
  }

  if $version in ['56', '5.6'] {
    class { 'yum::repo::mysql_community':
      enabled_version => '5.6',
    }
  }

  if $version in ['57', '5.7'] {
    class { 'yum::repo::mysql_community':
      enabled_version => '5.7',
    }
  }

}
