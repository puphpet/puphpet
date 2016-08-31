# Default module parameters
class rvm::params($manage_group = true) {

  $group = $::operatingsystem ? {
    default => 'rvm',
  }

  $proxy_url = undef
  $no_proxy = undef
  $key_server = 'keys.gnupg.net'

  $gpg_package = $::kernel ? {
    /(Linux|Darwin)/ => 'gnupg2',
    default          => undef,
  }
}
