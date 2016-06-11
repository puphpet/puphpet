class puphpet {
  $yaml = merge_yaml(
    '/vagrant/puphpet/config.yaml',
    "/vagrant/puphpet/config-${::provisioner_type}.yaml",
    '/vagrant/puphpet/config-custom.yaml'
  )

  $apache         = $yaml['apache']
  $beanstalkd     = hiera_hash('beanstalkd', {})
  $blackfire      = hiera_hash('blackfire', {})
  $cron           = hiera_hash('cron', {})
  $drush          = hiera_hash('drush', {})
  $elasticsearch  = hiera_hash('elastic_search', {})
  $firewall       = hiera_hash('firewall', {})
  $hhvm           = hiera_hash('hhvm', {})
  $letsencrypt    = hiera_hash('letsencrypt', {})
  $locales        = hiera_hash('locale', {})
  $mailhog        = hiera_hash('mailhog', {})
  $mariadb        = hiera_hash('mariadb', {})
  $mongodb        = hiera_hash('mongodb', {})
  $mysql          = hiera_hash('mysql', {})
  $nginx          = $yaml['nginx']
  $nodejs         = hiera_hash('nodejs', {})
  $php            = hiera_hash('php', {})
  $postgresql     = hiera_hash('postgresql', {})
  $python         = hiera_hash('python', {})
  $rabbitmq       = hiera_hash('rabbitmq', {})
  $redis          = hiera_hash('redis', {})
  $rubyhash       = hiera_hash('ruby', {})
  $server         = hiera_hash('server', {})
  $solr           = hiera_hash('solr', {})
  $sqlite         = hiera_hash('sqlite', {})
  $users_groups   = hiera_hash('users_groups', {})
  $vm             = hiera_hash('vagrantfile', {})
  $wpcli          = hiera_hash('wpcli', {})
  $xdebug         = hiera_hash('xdebug', {})
  $xhprof         = hiera_hash('xhprof', {})

  Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

  include ::puphpet::params

  if array_true($apache, 'install') {
    class { '::puphpet::apache':
      apache => $apache,
      php    => $php,
      hhvm   => $hhvm
    }
  }

  if array_true($beanstalkd, 'install') {
    class { '::puphpet::beanstalkd':
      beanstalkd => $beanstalkd,
      apache     => $apache,
      hhvm       => $hhvm,
      nginx      => $nginx,
      php        => $php
    }
  }

  class { '::puphpet::cron':
    cron => $cron,
  }

  if array_true($drush, 'install') {
    class { '::puphpet::drush':
      drush => $drush,
      php   => $php,
      hhvm  => $hhvm
    }
  }

  if array_true($elasticsearch, 'install') {
    class { '::puphpet::elasticsearch':
      elasticsearch => $elasticsearch
    }
  }

  class { '::puphpet::firewall':
    firewall => $firewall,
    vm       => $vm
  }

  if array_true($hhvm, 'install') {
    class { '::puphpet::hhvm':
      hhvm => $hhvm
    }
  }

  if array_true($mailhog, 'install') {
    class { '::puphpet::mailhog':
      mailhog => $mailhog
    }
  }

  if array_true($mariadb, 'install') and ! array_true($mysql, 'install') {
    class { '::puphpet::mariadb':
      mariadb => $mariadb,
      apache  => $apache,
      nginx   => $nginx,
      php     => $php,
      hhvm    => $hhvm
    }
  }

  if array_true($mongodb, 'install') {
    class { '::puphpet::mongodb':
      mongodb => $mongodb,
      apache  => $apache,
      nginx   => $nginx,
      php     => $php
    }
  }

  if array_true($mysql, 'install') and ! array_true($mariadb, 'install') {
    class { '::puphpet::mysql':
      mysql  => $mysql,
      apache => $apache,
      nginx  => $nginx,
      php    => $php,
      hhvm   => $hhvm
    }
  }

  if array_true($nginx, 'install') {
    class { '::puphpet::nginx':
      nginx => $nginx
    }
  }

  if array_true($nodejs, 'install') {
    class { '::puphpet::nodejs':
      nodejs => $nodejs
    }
  }

  if array_true($php, 'install') {
    class { '::puphpet::php':
      php     => $php,
      mailhog => $mailhog
    }

    if array_true($blackfire, 'install') {
      class { '::puphpet::blackfire':
        blackfire => $blackfire,
      }
    }

    if array_true($xdebug, 'install') {
      class { '::puphpet::xdebug':
        xdebug => $xdebug,
        php    => $php
      }
    }

    if array_true($xhprof, 'install') {
      class { '::puphpet::xhprof':
        xhprof => $xhprof,
        apache => $apache,
        nginx  => $nginx,
        php    => $php,
      }
    }
  }

  if array_true($postgresql, 'install') {
    class { '::puphpet::postgresql':
      postgresql => $postgresql,
      apache     => $apache,
      nginx      => $nginx,
      php        => $php,
      hhvm       => $hhvm
    }
  }

  if array_true($python, 'install') {
    class { '::puphpet::python':
      python => $python
    }
  }

  if array_true($rabbitmq, 'install') {
    class { '::puphpet::rabbitmq':
      rabbitmq => $rabbitmq,
      apache   => $apache,
      nginx    => $nginx,
      php      => $php
    }
  }

  if array_true($redis, 'install') {
    class { '::puphpet::redis':
      redis  => $redis,
      apache => $apache,
      nginx  => $nginx,
      php    => $php
    }
  }

  class { '::puphpet::ruby':
    ruby => $rubyhash
  }

  class { '::puphpet::server':
    server  => $server
  }

  if array_true($letsencrypt, 'install') {
    class { '::puphpet::letsencrypt':
      letsencrypt => $letsencrypt,
      apache      => $apache,
      nginx       => $nginx,
    }
  }

  class { '::puphpet::locale':
    locales => $locales
  }

  if array_true($solr, 'install') {
    class { '::puphpet::solr':
      solr => $solr
    }
  }

  if array_true($sqlite, 'install') {
    class { '::puphpet::sqlite':
      sqlite => $sqlite,
      apache => $apache,
      nginx  => $nginx,
      php    => $php,
      hhvm   => $hhvm
    }
  }

  class { '::puphpet::usersgroups':
    users_groups => $users_groups,
  }

  if array_true($wpcli, 'install') {
    class { '::puphpet::wpcli':
      wpcli => $wpcli,
      php   => $php,
      hhvm  => $hhvm
    }
  }

}
