# = Class: yum::repo::scl
#
# This class installs the scl repo
#
class yum::repo::scl (
  $baseurl = ''
) {

  $osver = split($::operatingsystemrelease, '[.]')
  $release = $::operatingsystem ? {
    /(?i:Centos|RedHat|Scientific)/ => $osver[0],
    default                         => '6',
  }

  $real_baseurl = $baseurl ? {
    ''      => "http://dev.centos.org/centos/${release}/SCL/\$basearch/",
    default => $baseurl,
  }

  yum::managed_yumrepo { 'scl':
    descr          => 'CentOS-$releasever - SCL',
    baseurl        => $real_baseurl,
    enabled        => 1,
    gpgcheck       => 0,
    priority       => 20,
    failovermethod => 'priority',
  }

}
