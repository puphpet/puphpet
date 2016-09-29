# Class for adding CentOS MariaDB repo
#
class puphpet::mariadb::repo::centos (
  $version = $::puphpet::mariadb::params::version
){

  $arch = $::architecture ? {
    'i386'   => 'x86',
    'amd64'  => 'amd64',
    'x86_64' => 'amd64'
  }
  $location = "http://yum.mariadb.org/${version}/centos6-${arch}"

  ::yum::managed_yumrepo { 'MariaDB':
    descr    => 'MariaDB - mariadb.org',
    baseurl  => $location,
    enabled  => 1,
    gpgcheck => 0,
    priority => 1
  }

}


