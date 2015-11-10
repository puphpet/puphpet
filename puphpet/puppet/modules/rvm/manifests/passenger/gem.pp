# Install the passenger gem
class rvm::passenger::gem($ruby_version, $version, $proxy_url = undef ) {
  $ruby_version_only = regsubst($ruby_version,'([^@]+)(@(.+))?','\1')
  rvm_gem {
    'passenger':
      ensure       => $version,
      require      => Rvm_system_ruby[$ruby_version_only],
      ruby_version => $ruby_version,
      proxy_url    => $proxy_url;
  }
}
