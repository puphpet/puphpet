# = Class: yum::repo::jpackage6
#
# This class installs the jpackage6 repo
#
class yum::repo::jenkins (
  $baseurl = 'http://pkg.jenkins-ci.org/redhat',
) {

  yum::managed_yumrepo { 'jenkins':
    descr          => 'Jenkins',
    baseurl        => $baseurl,
    failovermethod => 'priority',
    gpgcheck       => 1,
    gpgkey         => 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key',
    enabled        => 1,
    priority       => 1,
  }
}
