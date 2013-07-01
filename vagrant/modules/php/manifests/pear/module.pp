# Define: php::pear::module
#
# Installs the defined php pear component
#
# Variables:
# [*use_package*]
#   (default=true) - Tries to install pear module with the relevant OS package
#   If set to "no" it installs the module via pear command
#
# [*preferred_state*]
#   (default="stable") - Define which preferred state to use when installing
#   Pear modules via pear via command line (when use_package=false)
#
# [*alldeps*]
#   (default="false") - Define if all the available (optional) modules should
#   be installed. (when use_package=false)
#
# Usage:
# php::pear::module { packagename: }
# Example:
# php::pear::module { Crypt-CHAP: }
#
define php::pear::module ( 
  $service             = $php::service,
  $use_package         = true,
  $preferred_state     = 'stable',
  $alldeps             = false,
  $version             = 'present',
  $repository          = 'pear.php.net',
  $service_autorestart = $php::manage_service_autorestart,
  $module_prefix       = $php::pear_module_prefix,
  $ensure              = 'present'
  ) {

  include php::pear

  $bool_use_package = any2bool($use_package)
  $bool_alldeps = any2bool($alldeps)
  $manage_alldeps = $bool_alldeps ? {
    true  => '--alldeps',
    false => '',
  }
  $pear_source = $version ? {
    'present' => "${repository}/${name}",
    default   => "${repository}/${name}-${version}",
  }
  $pear_exec_command="pear -d preferred_state=${preferred_state} install ${manage_alldeps} ${pear_source}"

  case $bool_use_package {
    true: {
      package { "pear-${name}":
        name    => "${module_prefix}${name}",
        ensure  => $ensure,
        notify  => $service_autorestart,
      }
    }
    default: {
      if $repository != 'pear.php.net' {
        @php::pear::config { 'auto_discover':
          value => '1',
          before => Exec["pear-${name}"],
        }
        Php::Pear::Config <| title == 'auto_discover' |>
      }
      exec { "pear-${name}":
        command => $pear_exec_command,
        unless  => "pear info ${pear_source}",
        path    => $php::pear::path,
        require => Package['php-pear'],
      }
    }
  } # End Case
  
}
