# = Class: yum::repo::foreman
#
# This class installs the foreman repo
#
class yum::repo::foreman (
  $baseurl_main = 'http://yum.theforeman.org/stable/',
  $baseurl_plugins  = undef,
) {

  yum::managed_yumrepo { 'foreman':
    descr          => 'Foreman Repo',
    baseurl        => $baseurl_main,
    enabled        => 1,
    gpgcheck       => 1,
    failovermethod => 'priority',
    gpgkey         => 'http://yum.theforeman.org/RPM-GPG-KEY-foreman',
    priority       => 1,
  }

  if $baseurl_plugins {
    yum::managed_yumrepo { 'foreman_plugins':
      descr          => 'Foreman Plugins Repo',
      baseurl        => $baseurl_plugins,
      enabled        => 1,
      gpgcheck       => 0,
      failovermethod => 'priority',
      priority       => 1,
    }
  }

}

