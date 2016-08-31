# Private class
class mysql::bindings::ruby {

  package{ 'ruby_mysql':
    ensure          => $mysql::bindings::ruby_package_ensure,
    install_options => $mysql::bindings::install_options,
    name            => $mysql::bindings::ruby_package_name,
    provider        => $mysql::bindings::ruby_package_provider,
  }

}
