# Configures the Agent
class blackfire::agent::config inherits blackfire::agent {

  $ini_path = '/etc/blackfire/agent'
  $section = 'blackfire'

  ini_setting { 'ca-cert':
    ensure  => present,
    path    => $ini_path,
    section => $section,
    setting => 'ca-cert',
    value   => $::blackfire::agent::params['ca_cert']
  }

  ini_setting { 'collector':
    ensure  => present,
    path    => $ini_path,
    section => $section,
    setting => 'collector',
    value   => $::blackfire::agent::params['collector']
  }

  ini_setting { 'http_proxy':
    ensure  => present,
    path    => $ini_path,
    section => $section,
    setting => 'http-proxy',
    value   => $::blackfire::agent::params['http_proxy']
  }

  ini_setting { 'https_proxy':
    ensure  => present,
    path    => $ini_path,
    section => $section,
    setting => 'https-proxy',
    value   => $::blackfire::agent::params['https_proxy']
  }

  ini_setting { 'log-file':
    ensure  => present,
    path    => $ini_path,
    section => $section,
    setting => 'log-file',
    value   => $::blackfire::agent::params['log_file']
  }

  ini_setting { 'log-level':
    ensure  => present,
    path    => $ini_path,
    section => $section,
    setting => 'log-level',
    value   => $::blackfire::agent::params['log_level']
  }

  ini_setting { 'server-id':
    ensure  => present,
    path    => $ini_path,
    section => $section,
    setting => 'server-id',
    value   => $::blackfire::agent::params['server_id']
  }

  ini_setting { 'server-token':
    ensure  => present,
    path    => $ini_path,
    section => $section,
    setting => 'server-token',
    value   => $::blackfire::agent::params['server_token']
  }

  ini_setting { 'socket':
    ensure  => present,
    path    => $ini_path,
    section => $section,
    setting => 'socket',
    value   => $::blackfire::agent::params['socket']
  }

  ini_setting { 'spec':
    ensure  => present,
    path    => $ini_path,
    section => $section,
    setting => 'spec',
    value   => $::blackfire::agent::params['spec']
  }

}
