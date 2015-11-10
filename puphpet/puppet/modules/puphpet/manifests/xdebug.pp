class puphpet::xdebug (
  $install_cli = true,
  $webserver,
  $compile     = false,
  $ensure      = present
) inherits puphpet::params {

  warning('puphpet::xdebug is deprecated; please use puphpet::php::xdebug')

  class { '::puphpet::php::xdebug':
    install_cli => $install_cli,
    webserver   => $webserver,
    compile     => $compile,
    ensure      => $ensure,
  }
}
