# = Class: yum::repo::puppetdevel
#
# This class installs the puppetdevel repo
#
class yum::repo::puppetdevel (
  $baseurl_devel        = 'http://yum.puppetlabs.com/el/$releasever/devel/$basearch',
  $baseurl_dependencies = 'http://yum.puppetlabs.com/el/$releasever/dependencies/$basearch',
) {

  yum::managed_yumrepo { 'puppetlabs_devel':
    descr          => 'Puppet Labs Packages - Devel',
    baseurl        => $baseurl_devel,
    enabled        => 1,
    gpgcheck       => 1,
    failovermethod => 'priority',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
    gpgkey_source  => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-puppetlabs',
    priority       => 15,
  }

  yum::managed_yumrepo { 'puppetlabs_dependencies':
    descr          => 'Puppet Labs Packages - Dependencies',
    baseurl        => $baseurl_dependencies,
    enabled        => 1,
    gpgcheck       => 1,
    failovermethod => 'priority',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
    gpgkey_source  => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-puppetlabs',
    priority       => 15,
  }

}
