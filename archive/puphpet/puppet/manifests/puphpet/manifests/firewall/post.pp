# Blacklist everything not whitelisted previously
#
class puphpet::firewall::post {

  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }

}
