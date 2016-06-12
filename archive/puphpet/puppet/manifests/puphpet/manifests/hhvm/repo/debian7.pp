# Class for adding Debian Wheezy HHVM repo
#
class puphpet::hhvm::repo::debian7 {

  ::apt::source { 'dl.hhvm.com-debian-wheezy':
    location => 'http://dl.hhvm.com/debian',
    release  => 'wheezy',
    repos    => 'main',
    key      => {
      'id'     => '0x5a16e7281be7a449',
      'server' => 'hkp://keyserver.ubuntu.com:80',
    },
    require  => [
      Package['debian-keyring'],
      Package['debian-archive-keyring'],
    ],
  }

}
