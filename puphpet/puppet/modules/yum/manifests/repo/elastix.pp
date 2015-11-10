# = Class: yum::repo::elastix
#
# This class installs the elastix repo
#
class yum::repo::elastix {

  yum::managed_yumrepo { 'elastix-base':
    descr          => 'Base RPM Repository for Elastix',
    mirrorlist     => 'http://mirror.elastix.org/?release=2&arch=$basearch&repo=base',
    enabled        => 1,
    gpgcheck       => 1,
    gpgkey         => 'http://repo.elastix.org/elastix/RPM-GPG-KEY-Elastix',
    autokeyimport  => 'yes',
  }

  yum::managed_yumrepo { 'elastix-updates':
    descr          => 'Updates RPM Repository for Elastix',
    mirrorlist     => 'http://mirror.elastix.org/?release=2&arch=$basearch&repo=updates',
    enabled        => 1,
    gpgcheck       => 1,
    gpgkey         => 'http://repo.elastix.org/elastix/RPM-GPG-KEY-Elastix',
  }

  yum::managed_yumrepo { 'elastix-beta':
    descr          => 'Beta RPM Repository for Elastix',
    mirrorlist     => 'http://mirror.elastix.org/?release=2&arch=$basearch&repo=beta',
    enabled        => 0,
    gpgcheck       => 1,
    gpgkey         => 'http://repo.elastix.org/elastix/RPM-GPG-KEY-Elastix',
  }

  yum::managed_yumrepo { 'elastix-extras':
    descr          => 'Extras RPM Repository for Elastix',
    mirrorlist     => 'http://mirror.elastix.org/?release=2&arch=$basearch&repo=extras',
    enabled        => 1,
    gpgcheck       => 1,
    gpgkey         => 'http://repo.elastix.org/elastix/RPM-GPG-KEY-Elastix',
  }

  yum::managed_yumrepo { 'elastix-commercial-addons':
    descr          => 'Commercial-Addons RPM Repository for Elastix',
    mirrorlist     => 'http://mirror.elastix.org/?release=2&arch=$basearch&repo=commercial_addons',
    enabled        => 1,
    gpgcheck       => 1,
    gpgkey         => 'http://repo.elastix.org/elastix/RPM-GPG-KEY-Elastix',
  }

  yum::managed_yumrepo { 'elastix-LowayResearch':
    descr          => 'Loway Research Yum Repository',
    baseurl        => 'http://yum.loway.ch/RPMS',
    enabled        => 1,
    gpgcheck       => 0,
  }
  
}
