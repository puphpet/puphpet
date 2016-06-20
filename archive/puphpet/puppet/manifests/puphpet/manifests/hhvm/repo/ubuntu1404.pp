# Class for adding Ubuntu 14.04 HHVM repo
#
class puphpet::hhvm::repo::ubuntu1404 {

  ::apt::source { 'dl.hhvm.com-ubuntu-trusty':
    location => 'http://dl.hhvm.com/ubuntu',
    release  => 'trusty',
    repos    => 'main',
    key      => {
      'id'     => '0x5a16e7281be7a449',
      'server' => 'hkp://keyserver.ubuntu.com:80',
    },
  }

}
