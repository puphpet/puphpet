# This depends on puppetlabs/firewall: https://github.com/puppetlabs/puppetlabs-firewall
# Firewall rules to be setup after custom rules
class puphpet::firewall::post {

  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }

}
