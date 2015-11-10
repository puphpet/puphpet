# Private class
class mysql::bindings::daemon_dev {

  if $mysql::bindings::daemon_dev_package_name {
    package { 'mysql-daemon_dev':
      ensure          => $mysql::bindings::daemon_dev_package_ensure,
      install_options => $mysql::bindings::install_options,
      name            => $mysql::bindings::daemon_dev_package_name,
      provider        => $mysql::bindings::daemon_dev_package_provider,
    }
  } else {
    warning("No MySQL daemon development package configured for ${::operatingsystem}.")
  }

}
