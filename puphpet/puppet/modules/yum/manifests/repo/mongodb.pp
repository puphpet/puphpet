# = Class: yum::repo::mongodb
#
# This class installs the mongodb repo
#
class yum::repo::mongodb (
  $baseurl = 'http://downloads-distro.mongodb.org/repo/redhat/os/x86_64',
) {

  yum::managed_yumrepo { 'mongodb':
    descr     => '10gen MongoDB Repo',
    baseurl   => $baseurl,
    enabled   => 1,
    gpgcheck  => 0,
  }

}

