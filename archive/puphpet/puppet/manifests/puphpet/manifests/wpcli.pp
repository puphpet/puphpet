# Class for installing WP CLI tool
#
# PHP and Composer must be selected for install
#
class puphpet::wpcli {

  include ::puphpet::params

  $wpcli = $puphpet::params::hiera['wpcli']
  $php   = $puphpet::params::hiera['php']
  $hhvm  = $puphpet::params::hiera['hhvm']

  $version  = $wpcli['version'] != undef
  $engine   = (array_true($php, 'install') or array_true($hhvm, 'install'))
  $composer = (array_true($php, 'composer') or array_true($hhvm, 'composer'))

  # Requires either PHP or HHVM, and Composer
  if $version and $engine and $composer {
    class { 'puphpet::php::wpcli::install' :
      version => $wpcli['version']
    }
  }

}
