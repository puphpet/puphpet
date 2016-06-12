# Class for installing firewall and configuring base rules
#
class puphpet::firewall::install {

  Firewall {
    before  => Class['puphpet::firewall::post'],
    require => Class['puphpet::firewall::pre'],
  }

  class {'puphpet::firewall::pre': }

  class {'puphpet::firewall::post': }

  class {'firewall': }

}
