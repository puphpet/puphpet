# Installs and configures Blackfire agent and PHP extension
class blackfire (
  $server_id = $blackfire::params::server_id,
  $server_token = $blackfire::params::server_token,
  $agent = $blackfire::params::agent,
  $php = $blackfire::params::php,
  $manage_repo = $blackfire::params::manage_repo
) inherits blackfire::params {

  validate_string($server_id)
  validate_string($server_token)
  if !$server_id or !$server_token {
    fail 'server_id and server_token are required. Get them on https://blackfire.io/account/agents'
  }
  validate_hash($agent)
  validate_hash($php)
  validate_bool($manage_repo)

  anchor { '::blackfire::begin': } ->
  class { '::blackfire::repo': } ->
  class { '::blackfire::agent': } ~>
  class { '::blackfire::php': } ~>
  anchor { '::blackfire::end': }

}
