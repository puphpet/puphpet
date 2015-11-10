class yum::repo::vmware_tools (
  $baseurl = 'http://packages.vmware.com/tools/esx/5.1latest/rhel$releasever/$basearch',
) {

  yum::managed_yumrepo { 'vmware-tools':
    descr          => 'VMware Tools',
    baseurl        => $baseurl,
    enabled        => 1,
    gpgcheck       => 1,
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-VMWARE-PACKAGING',
    gpgkey_source  => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-VMWARE-PACKAGING',
    priority       => 90,
    failovermethod => 'priority',
  }

}
