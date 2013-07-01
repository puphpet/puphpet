# Class php::devel
#
# Installs php devel package
#
class php::devel {

  if $php::package_devel != '' {
    package { 'php-devel':
      ensure => $php::manage_package,
      name   => $php::package_devel,
    }
  }
}
