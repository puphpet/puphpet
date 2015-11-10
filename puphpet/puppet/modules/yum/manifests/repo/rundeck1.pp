class yum::repo::rundeck1 {

  require yum

  yum::managed_yumrepo { 'rundeck-release':
    descr          => 'Rundeck Release',
    baseurl        => 'http://repo.rundeck.org/repo/rundeck/1/release',
    enabled        => 0,
    gpgcheck       => 0,
    priority       => 80,
    failovermethod => 'priority',
  }

  yum::managed_yumrepo { 'rundeck-updates':
    descr          => 'Rundeck Updates',
    baseurl        => 'http://repo.rundeck.org/repo/rundeck/1/updates',
    enabled        => 0,
    gpgcheck       => 0,
    priority       => 80,
    failovermethod => 'priority',
  }

  yum::managed_yumrepo { 'rundeck-bleeding':
    descr          => 'Rundeck Bleeding Edge',
    baseurl        => 'http://repo.rundeck.org/repo/rundeck/1/bleedingedge',
    enabled        => 0,
    gpgcheck       => 0,
    priority       => 80,
    failovermethod => 'priority',
  }

}
