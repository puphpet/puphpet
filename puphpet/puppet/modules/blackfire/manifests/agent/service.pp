# Manages the agent service
class blackfire::agent::service inherits blackfire::agent {

  if ! ($::blackfire::agent::params['service_ensure'] in ['running', 'stopped']) {
    fail('service_ensure parameter must be running or stopped')
  }

  if $::blackfire::agent::params['manage_service'] {
    service { 'blackfire-agent':
      ensure => $::blackfire::agent::params['service_ensure'],
    }
  }

}
