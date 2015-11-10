# Installs and configures Blackfire PHP extension
class blackfire::php inherits blackfire {

  $default_params = {
    manage => true,
    version => 'latest',
    server_id => $::blackfire::server_id,
    server_token => $::blackfire::server_token,
    agent_socket => 'unix:///var/run/blackfire/agent.sock',
    log_file => '',
    log_level => 1,
    agent_timeout => 0.25,
  }
  $params = merge($default_params, $::blackfire::params)

  validate_bool($params['manage'])
  validate_string($params['version'])
  validate_string($params['server_id'])
  validate_string($params['server_token'])
  validate_string($params['socket'])
  validate_string($params['log_file'])
  if $params['log_level'] < 1 or $params['log_level'] > 4 {
    fail 'Ivalid log_level. Valid levels are: 4 - debug, 3 - info, 2 - warning, 1 - error'
  }

  anchor { '::blackfire::php::begin': } ->
    class { '::blackfire::php::install': } ->
    class { '::blackfire::php::config': } ~>
  anchor { '::blackfire::php::end': }

}
