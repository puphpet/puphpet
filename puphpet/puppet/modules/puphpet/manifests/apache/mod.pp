# This depends on puppetlabs/apache: https://github.com/puppetlabs/puppetlabs-apache
# Installs Apache mod, filtering out from list of disallowed
define puphpet::apache::mod (
  $disallowed_modules = [],
) {
  if ! defined(Class["apache::mod::${name}"])
    and !($name in $disallowed_modules)
  {
    class { "apache::mod::${name}": }
  }
}
