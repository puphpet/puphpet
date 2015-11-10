# This depends on puppetlabs/firewall: https://github.com/puppetlabs/puppetlabs-firewall
# Adds a firewall rule
define puphpet::firewall::port (
  $protocol = tcp,
  $action   = 'accept',
  $priority = 100,
) {
  $port = $name

  $rule_name = "${priority} ${protocol}/${port}"

  if ! defined(Firewall[$rule_name]) {
    firewall { $rule_name:
      port   => $port,
      proto  => $protocol,
      action => $action,
    }
  }
}
