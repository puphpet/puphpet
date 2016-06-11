class puphpet {

  include ::puphpet::params

  Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

  class { '::puphpet::cron': }
  class { '::puphpet::firewall': }
  class { '::puphpet::locale': }
  class { '::puphpet::ruby': }
  class { '::puphpet::server': }
  class { '::puphpet::usersgroups': }

  if array_true($puphpet::params::config['apache'], 'install') {
    class { '::puphpet::apache': }
  }

  if array_true($puphpet::params::config['beanstalkd'], 'install') {
    class { '::puphpet::beanstalkd': }
  }

  if array_true($puphpet::params::config['drush'], 'install') {
    class { '::puphpet::drush': }
  }

  if array_true($puphpet::params::config['elasticsearch'], 'install') {
    class { '::puphpet::elasticsearch': }
  }

  if array_true($puphpet::params::config['hhvm'], 'install') {
    class { '::puphpet::hhvm': }
  }

  if array_true($puphpet::params::config['mailhog'], 'install') {
    class { '::puphpet::mailhog': }
  }

  if array_true($puphpet::params::config['mariadb'], 'install')
    and ! array_true($puphpet::params::config['mysql'], 'install')
  {
    class { '::puphpet::mariadb': }
  }

  if array_true($puphpet::params::config['mongodb'], 'install') {
    class { '::puphpet::mongodb': }
  }

  if array_true($puphpet::params::config['mysql'], 'install')
    and ! array_true($puphpet::params::config['mariadb'], 'install')
  {
    class { '::puphpet::mysql': }
  }

  if array_true($puphpet::params::config['nginx'], 'install') {
    class { '::puphpet::nginx': }
  }

  if array_true($puphpet::params::config['nodejs'], 'install') {
    class { '::puphpet::nodejs': }
  }

  if array_true($puphpet::params::config['php'], 'install') {
    class { '::puphpet::php': }

    if array_true($puphpet::params::config['blackfire'], 'install') {
      class { '::puphpet::blackfire': }
    }

    if array_true($puphpet::params::config['xdebug'], 'install') {
      class { '::puphpet::xdebug': }
    }

    if array_true($puphpet::params::config['xhprof'], 'install') {
      class { '::puphpet::xhprof': }
    }
  }

  if array_true($puphpet::params::config['postgresql'], 'install') {
    class { '::puphpet::postgresql': }
  }

  if array_true($puphpet::params::config['python'], 'install') {
    class { '::puphpet::python': }
  }

  if array_true($puphpet::params::config['rabbitmq'], 'install') {
    class { '::puphpet::rabbitmq': }
  }

  if array_true($puphpet::params::config['redis'], 'install') {
    class { '::puphpet::redis': }
  }

  if array_true($puphpet::params::config['letsencrypt'], 'install') {
    class { '::puphpet::letsencrypt': }
  }

  if array_true($puphpet::params::config['solr'], 'install') {
    class { '::puphpet::solr': }
  }

  if array_true($puphpet::params::config['sqlite'], 'install') {
    class { '::puphpet::sqlite': }
  }

  if array_true($puphpet::params::config['wpcli'], 'install') {
    class { '::puphpet::wpcli': }
  }

}
