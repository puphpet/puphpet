# = Class: yum::repo::puppetlabs
#
# This class installs the puppetlabs repo
#
class yum::repo::puppetlabs (
  $baseurl_products     = '',
  $baseurl_dependencies = '',
) {
  $osver = split($::operatingsystemrelease, '[.]')
  $release = $::operatingsystem ? {
    /(?i:Centos|RedHat|Scientific|CloudLinux)/ => $osver[0],
    default                         => '6',
  }

  $real_baseurl_products = $baseurl_products ? {
    ''      => "http://yum.puppetlabs.com/el/${release}/products/\$basearch",
    default => $baseurl_products,
  }

  $real_baseurl_dependencies = $baseurl_dependencies ? {
    ''      => "http://yum.puppetlabs.com/el/${release}/dependencies/\$basearch",
    default => $baseurl_dependencies,
  }

  yum::managed_yumrepo { 'puppetlabs':
    descr          => 'Puppet Labs Packages',
    baseurl        => $real_baseurl_products,
    enabled        => 1,
    gpgcheck       => 1,
    failovermethod => 'priority',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
    gpgkey_source  => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-puppetlabs',
    priority       => 1,
  }

  # The dependencies repo has the same priority as base,
  # because it needs to override base packages.
  # E.g. puppet-3.0 requires Ruby => 1.8.7, but EL5 ships with 1.8.5.
  #
  yum::managed_yumrepo { 'puppetlabs_dependencies':
    descr          => 'Puppet Labs Packages',
    baseurl        => $real_baseurl_dependencies,
    enabled        => 1,
    gpgcheck       => 1,
    failovermethod => 'priority',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
    gpgkey_source  => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-puppetlabs',
    priority       => 1,
  }

}
