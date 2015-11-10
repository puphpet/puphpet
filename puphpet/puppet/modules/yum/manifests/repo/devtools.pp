#
# This class installs the devtools repo
#
class yum::repo::devtools (
  $baseurl = 'http://people.centos.org/tru/devtools-1.1/$releasever/$basearch/RPMS'
) {

  require yum

  yum::managed_yumrepo { 'devtools':
    descr          => 'Devtools for CentOS',
    baseurl        => $baseurl,
    enabled        => 1,
    gpgcheck       => 0,
    priority       => 90,
  }
}
