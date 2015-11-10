# Installs the agent
class blackfire::agent::install inherits blackfire::agent {
  package { 'blackfire-agent':
    ensure => $::blackfire::agent::params['version'],
  }
}
