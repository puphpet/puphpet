# See README.md.
class mysql::bindings (
  $install_options = undef,
  # Boolean to determine if we should include the classes.
  $java_enable     = false,
  $perl_enable     = false,
  $php_enable      = false,
  $python_enable   = false,
  $ruby_enable     = false,
  $client_dev      = false,
  $daemon_dev      = false,
  # Settings for the various classes.
  $java_package_ensure         = $mysql::params::java_package_ensure,
  $java_package_name           = $mysql::params::java_package_name,
  $java_package_provider       = $mysql::params::java_package_provider,
  $perl_package_ensure         = $mysql::params::perl_package_ensure,
  $perl_package_name           = $mysql::params::perl_package_name,
  $perl_package_provider       = $mysql::params::perl_package_provider,
  $php_package_ensure          = $mysql::params::php_package_ensure,
  $php_package_name            = $mysql::params::php_package_name,
  $php_package_provider        = $mysql::params::php_package_provider,
  $python_package_ensure       = $mysql::params::python_package_ensure,
  $python_package_name         = $mysql::params::python_package_name,
  $python_package_provider     = $mysql::params::python_package_provider,
  $ruby_package_ensure         = $mysql::params::ruby_package_ensure,
  $ruby_package_name           = $mysql::params::ruby_package_name,
  $ruby_package_provider       = $mysql::params::ruby_package_provider,
  $client_dev_package_ensure   = $mysql::params::client_dev_package_ensure,
  $client_dev_package_name     = $mysql::params::client_dev_package_name,
  $client_dev_package_provider = $mysql::params::client_dev_package_provider,
  $daemon_dev_package_ensure   = $mysql::params::daemon_dev_package_ensure,
  $daemon_dev_package_name     = $mysql::params::daemon_dev_package_name,
  $daemon_dev_package_provider = $mysql::params::daemon_dev_package_provider
) inherits mysql::params {

  case $::osfamily {
    'Archlinux': {
      if $java_enable   { fail("::mysql::bindings::java cannot be managed by puppet on ${::osfamily} as it is not in official repositories. Please disable java mysql binding.") }
      if $perl_enable   { include '::mysql::bindings::perl' }
      if $php_enable    { warning("::mysql::bindings::php does not need to be managed by puppet on ${::osfamily} as it is included in mysql package by default.") }
      if $python_enable { include '::mysql::bindings::python' }
      if $ruby_enable   { fail("::mysql::bindings::ruby cannot be managed by puppet on ${::osfamily} as it is not in official repositories. Please disable ruby mysql binding.") }
    }

    default: {
      if $java_enable   { include '::mysql::bindings::java' }
      if $perl_enable   { include '::mysql::bindings::perl' }
      if $php_enable    { include '::mysql::bindings::php' }
      if $python_enable { include '::mysql::bindings::python' }
      if $ruby_enable   { include '::mysql::bindings::ruby' }
    }
  }

  if $client_dev    { include '::mysql::bindings::client_dev' }
  if $daemon_dev    { include '::mysql::bindings::daemon_dev' }

}
