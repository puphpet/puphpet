class mysql::client::install {

  if $mysql::client::package_manage {

    package { 'mysql_client':
      ensure          => $mysql::client::package_ensure,
      install_options => $mysql::client::install_options,
      name            => $mysql::client::package_name,
    }

  }

}
