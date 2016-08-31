class puphpet::mysql::repo(
  $version
) {

  if ! ($version in ['55', '5.5', '56', '5.6']) {
    fail ( 'puphpet::mysql::repo only supports MySQL version 5.5 and 5.6' )
  }

  if $version in ['55', '5.5'] {
    case $::operatingsystem {
      'debian': {
        if ! defined(Apt::Source['packages.dotdeb.org-repo.puphpet']) {
          apt::source { 'packages.dotdeb.org-repo.puphpet':
            location          => 'http://repo.puphpet.com/dotdeb/',
            release           => $::lsbdistcodename,
            repos             => 'all',
            required_packages => 'debian-keyring debian-archive-keyring',
            key               => '89DF5277',
            key_server        => 'hkp://keyserver.ubuntu.com:80',
            include_src       => true
          }
        }
      }
      'ubuntu': {
        if ! defined(Apt::Key['E5267A6C']){
          apt::key { 'E5267A6C':
            key_server => 'hkp://keyserver.ubuntu.com:80'
          }
        }

        if $::lsbdistcodename in ['lucid', 'precise'] {
          apt::ppa { 'ppa:ondrej/mysql-5.5':
            require => Apt::Key['E5267A6C'],
            options => ''
          }
        } else {
          apt::ppa { 'ppa:ondrej/mysql-5.5':
            require => Apt::Key['E5267A6C']
          }
        }
      }
      'redhat', 'centos': {
        class { 'yum::repo::mysql_community':
          enabled_version => '5.5',
        }
      }
    }
  }

  if $version in ['56', '5.6'] {
    case $::operatingsystem {
      'debian': {
        if ! defined(Apt::Source['packages.dotdeb.org-repo.puphpet']) {
          apt::source { 'packages.dotdeb.org-repo.puphpet':
            location          => 'http://repo.puphpet.com/dotdeb/',
            release           => $::lsbdistcodename,
            repos             => 'all',
            required_packages => 'debian-keyring debian-archive-keyring',
            key               => '89DF5277',
            key_server        => 'hkp://keyserver.ubuntu.com:80',
            include_src       => true
          }
        }
      }
      'ubuntu': {
        if ! defined(Apt::Key['E5267A6C']){
          apt::key { 'E5267A6C':
            key_server => 'hkp://keyserver.ubuntu.com:80'
          }
        }

        if $::lsbdistcodename in ['lucid', 'precise'] {
          apt::ppa { 'ppa:ondrej/mysql-5.6':
            require => Apt::Key['E5267A6C'],
            options => ''
          }
        } else {
          apt::ppa { 'ppa:ondrej/mysql-5.6':
            require => Apt::Key['E5267A6C']
          }
        }
      }
      'redhat', 'centos': {
        class { 'yum::repo::mysql_community':
          enabled_version => '5.6',
        }
      }
    }
  }

}
