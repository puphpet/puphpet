# This depends on puppetlabs/apt: https://github.com/puppetlabs/puppetlabs-apt
# Adds Apache 2.4 repo for Debian Wheezy
class puphpet::apache::repo::debian {

  apt::source { 'd7031.de':
    location          => 'http://www.d7031.de/debian/',
    release           => 'wheezy-experimental',
    repos             => 'main',
    required_packages => 'debian-keyring debian-archive-keyring',
    key               => {
      'id'      => '9EB5E8A3DF17D0B3',
      'server'  => 'hkp://keyserver.ubuntu.com:80',
    },
    include           => { 'src' => true }
  }

}
