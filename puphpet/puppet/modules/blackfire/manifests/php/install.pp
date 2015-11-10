# Installs the PHP extension
class blackfire::php::install inherits blackfire::php {
  package { 'blackfire-php':
    ensure => $::blackfire::php::params['version'],
  }
}
