class puphpet::mysql::repo(
  $version
) {

  if $version in ['55', '5.5'] {
    case $::operatingsystem {
      'debian': {
        if ! defined(Apt::Source['packages.dotdeb.org-repo.puphpet']) {
          apt::source { 'packages.dotdeb.org-repo.puphpet':
            location          => 'http://repo.puphpet.com/dotdeb/',
            release           => $::lsbdistcodename,
            repos             => 'all',
            required_packages => 'debian-keyring debian-archive-keyring',
            key               => {
              'id'      => '89DF5277',
              'server'  => 'hkp://keyserver.ubuntu.com:80',
            },
            include           => { 'src' => true }
          }
        }
      }
      'ubuntu': {
        if ! defined(Apt::Key['14AA40EC0831756756D7F66C4F4EA0AAE5267A6C']){
          apt::key { '14AA40EC0831756756D7F66C4F4EA0AAE5267A6C':
            server => 'hkp://keyserver.ubuntu.com:80'
          }
        }

        if $::lsbdistcodename in ['lucid', 'precise'] {
          apt::ppa { 'ppa:ondrej/mysql-5.5':
            require => Apt::Key['14AA40EC0831756756D7F66C4F4EA0AAE5267A6C'],
            options => ''
          }
        } else {
          apt::ppa { 'ppa:ondrej/mysql-5.5':
            require => Apt::Key['14AA40EC0831756756D7F66C4F4EA0AAE5267A6C']
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
    case $::osfamily {
      'debian': {
        $os = downcase($::operatingsystem)

        ::apt::pin { 'repo.mysql.com-apt':
          priority   => 1000,
          originator => 'repo.mysql.com-apt',
        }

        if ! defined(Apt::Source['repo.mysql.com-apt']) {
          apt::source { 'repo.mysql.com-apt':
            location          => "http://repo.mysql.com/apt/${os}",
            release           => $::lsbdistcodename,
            repos             => 'mysql-5.6',
            required_packages => 'debian-keyring debian-archive-keyring',
            include           => { 'src' => true },
            require           => Apt::Pin['repo.mysql.com-apt'],
          }
        }
      }
      'redhat': {
        class { 'yum::repo::mysql_community':
          enabled_version => '5.6',
        }
      }
    }
  }

  if $version in ['57', '5.7'] {
    case $::osfamily {
      'debian': {
        $os = downcase($::operatingsystem)

        ::apt::pin { 'repo.mysql.com-apt':
          priority   => 1000,
          originator => 'repo.mysql.com-apt',
        }

        if ! defined(Apt::Source['repo.mysql.com-apt']) {
          apt::source { 'repo.mysql.com-apt':
            location          => "http://repo.mysql.com/apt/${os}",
            release           => $::lsbdistcodename,
            repos             => 'mysql-5.7',
            required_packages => 'debian-keyring debian-archive-keyring',
            include           => { 'src' => true },
            require           => Apt::Pin['repo.mysql.com-apt'],
          }
        }
      }
      'redhat': {
        class { 'yum::repo::mysql_community':
          enabled_version => '5.7',
        }
      }
    }
  }

}
