# Installs and configures Blackfire agent
class blackfire::agent inherits blackfire {

  $default_params = {
    manage => true,
    version => 'latest',
    manage_service => true,
    service_ensure => 'running',
    server_id => $::blackfire::server_id,
    server_token => $::blackfire::server_token,
    socket => 'unix:///var/run/blackfire/agent.sock',
    log_file => 'stderr',
    log_level => 1,
    collector => 'https://blackfire.io',
    http_proxy => '',
    https_proxy => '',
    ca_cert => '',
    spec => '',
  }
  $params = merge($default_params, $::blackfire::agent)

  validate_bool($params['manage'])
  validate_string($params['version'])
  validate_bool($params['manage_service'])
  validate_string($params['running'])
  validate_string($params['server_id'])
  validate_string($params['server_token'])
  validate_string($params['socket'])
  validate_string($params['log_file'])
  if $params['log_level'] < 1 or $params['log_level'] > 4 {
    fail 'Ivalid log_level. Valid levels are: 4 - debug, 3 - info, 2 - warning, 1 - error'
  }
  validate_string($params['collector'])
  validate_string($params['http_proxy'])
  validate_string($params['https_proxy'])
  validate_string($params['ca_cert'])
  validate_string($params['spec'])

  if $params['manage'] == true {
    anchor { '::blackfire::agent::begin': } ->
    class { '::blackfire::agent::install': } ->
    class { '::blackfire::agent::config': } ~>
    class { '::blackfire::agent::service': } ~>
    anchor { '::blackfire::agent::end': }
  }

}
