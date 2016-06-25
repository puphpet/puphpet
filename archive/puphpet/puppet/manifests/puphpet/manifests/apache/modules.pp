# == Define Resource Type: puphpet::apache::modules
#
# Installs Apache modules.
# Some specific modules extra work before they can be installed.
#
# Usage:
#
#  puphpet::apache::modules { 'name':
#    modules => [
#      'proxy_fcgi',
#      'rewrite',
#    ],
#  }
#
define puphpet::apache::modules (
  $modules = $::puphpet::apache::params::modules
) {

  include ::apache::params
  include ::puphpet::apache::params

  $apache = $puphpet::params::hiera['apache']

  # Remove some modules needing extra attention
  $modules_filtered = delete($modules, ['proxy_fcgi', 'pagespeed', 'ssl'])
  each( $modules_filtered ) |$module| {
    if ! defined(Apache::Mod[$module]) {
      ::apache::mod { $module: }
    }
  }

  if ('proxy_fcgi' in $modules)
    and ! defined(Class['puphpet::apache::module::proxy_fcgi'])
  {
    class { 'puphpet::apache::module::proxy_fcgi': }
  }

  if ('pagespeed' in $modules)
    and ! defined(Class['puphpet::apache::module::pagespeed'])
  {
    class { 'puphpet::apache::module::pagespeed': }
  }

  each( $puphpet::apache::params::system_modules ) |$package| {
    if ! defined(Package[$package]) {
      package { $package:
        ensure  => present,
        require => Class['apache'],
        notify  => Service[$::apache::params::service_name],
      }
    }
  }

  if $::osfamily == 'redhat'
    and $puphpet::apache::params::package_version == '2.4'
    and ! defined(Class['apache::mod::ssl'])
  {
    class { '::apache::mod::ssl':
      package_name => "${$puphpet::apache::params::module_prefix}_ssl",
    }
  }

}
