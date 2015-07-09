$yaml = merge_yaml(
  '/vagrant/puphpet/config.yaml',
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
$locales        = hiera_hash('locales', {})
$mailcatcher    = hiera_hash('mailcatcher', {})
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
$ruby           = hiera_hash('ruby', {})
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

import 'nodes/*'

if array_true($apache, 'install') {
  class { '::puphpet_apache':
    apache => $apache,
    php    => $php,
    hhvm   => $hhvm
  }
}

if array_true($beanstalkd, 'install') {
  class { '::puphpet_beanstalkd':
    beanstalkd => $beanstalkd,
    apache     => $apache,
    hhvm       => $hhvm,
    nginx      => $nginx,
    php        => $php
  }
}

class { '::puphpet_cron':
  cron => $cron,
}

if array_true($drush, 'install') {
  class { '::puphpet_drush':
    drush => $drush,
    php   => $php,
    hhvm  => $hhvm
  }
}

if array_true($elasticsearch, 'install') {
  class { '::puphpet_elasticsearch':
    elasticsearch => $elasticsearch
  }
}

class { '::puphpet_firewall':
  firewall => $firewall,
  vm       => $vm
}

if array_true($hhvm, 'install') {
  class { '::puphpet_hhvm':
    hhvm => $hhvm
  }
}

if array_true($mailcatcher, 'install') {
  class { '::puphpet_mailcatcher':
    mailcatcher => $mailcatcher
  }
}

if array_true($mariadb, 'install') and ! array_true($mysql, 'install') {
  class { '::puphpet_mariadb':
    mariadb => $mariadb,
    apache  => $apache,
    nginx   => $nginx,
    php     => $php,
    hhvm    => $hhvm
  }
}

if array_true($mongodb, 'install') {
  class { '::puphpet_mongodb':
    mongodb => $mongodb,
    apache  => $apache,
    nginx   => $nginx,
    php     => $php
  }
}

if array_true($mysql, 'install') and ! array_true($mariadb, 'install') {
  class { '::puphpet_mysql':
    mysql  => $mysql,
    apache => $apache,
    nginx  => $nginx,
    php    => $php,
    hhvm   => $hhvm
  }
}

if array_true($nginx, 'install') {
  class { '::puphpet_nginx':
    nginx => $nginx
  }
}

if array_true($nodejs, 'install') {
  class { '::puphpet_nodejs':
    nodejs => $nodejs
  }
}

if array_true($php, 'install') {
  class { '::puphpet_php':
    php         => $php,
    mailcatcher => $mailcatcher
  }

  if array_true($blackfire, 'install') {
    class { '::puphpet_blackfire':
      blackfire => $blackfire,
    }
  }

  if array_true($xdebug, 'install') {
    class { '::puphpet_xdebug':
      xdebug => $xdebug,
      php    => $php
    }
  }

  if array_true($xhprof, 'install') {
    class { '::puphpet_xhprof':
      xhprof => $xhprof,
      apache => $apache,
      nginx  => $nginx,
      php    => $php,
    }
  }
}

if array_true($postgresql, 'install') {
  class { '::puphpet_postgresql':
    postgresql => $postgresql,
    apache     => $apache,
    nginx      => $nginx,
    php        => $php,
    hhvm       => $hhvm
  }
}

if array_true($python, 'install') {
  class { '::puphpet_python':
    python => $python
  }
}

if array_true($rabbitmq, 'install') {
  class { '::puphpet_rabbitmq':
    rabbitmq => $rabbitmq,
    apache   => $apache,
    nginx    => $nginx,
    php      => $php
  }
}

if array_true($redis, 'install') {
  class { '::puphpet_redis':
    redis  => $redis,
    apache => $apache,
    nginx  => $nginx,
    php    => $php
  }
}

class { '::puphpet_ruby':
  ruby => $ruby
}

class { '::puphpet_server':
  server  => $server
}

class { '::puphpet_locale':
  locales => $locales
}

if array_true($solr, 'install') {
  class { '::puphpet_solr':
    solr => $solr
  }
}

# puppet manifests for mailcatcher and sqlite are not compatible
if array_true($sqlite, 'install') and ! array_true($mailcatcher, 'install') {
  class { '::puphpet_sqlite':
    sqlite => $sqlite,
    apache => $apache,
    nginx  => $nginx,
    php    => $php,
    hhvm   => $hhvm
  }
}

class { '::puphpet_usersgroups':
  users_groups => $users_groups,
}

if array_true($wpcli, 'install') {
  class { '::puphpet_wpcli':
    wpcli => $wpcli,
    php   => $php,
    hhvm  => $hhvm
  }
}
