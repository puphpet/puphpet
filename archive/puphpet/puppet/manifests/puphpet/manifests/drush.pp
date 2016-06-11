# Class for installing Drush CLI tool
#
# PHP or HHVM must be flagged for installation.
#
class puphpet::drush {

  include ::puphpet::params

  $drush = $puphpet::params::hiera['drush']
  $php   = $puphpet::params::hiera['php']
  $hhvm  = $puphpet::params::hiera['hhvm']

  $version  = $drush['version'] != undef
  $engine   = (array_true($php, 'install') or array_true($hhvm, 'install'))
  $composer = (array_true($php, 'composer') or array_true($hhvm, 'composer'))

  # Requires either PHP or HHVM, and Composer
  if $version and $engine and $composer {
    class { 'puphpet::php::drush':
      version => $drush['version']
    }
  }

}
