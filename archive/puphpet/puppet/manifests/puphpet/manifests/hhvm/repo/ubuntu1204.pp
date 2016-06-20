# Class for adding Ubuntu 12.04 HHVM repo
#
class puphpet::hhvm::repo::ubuntu1204 {

  apt::key { 'A6729974D728D7BA84154F8E4F7B93595D50B6BA':
    server => 'hkp://keyserver.ubuntu.com:80'
  }

  apt::ppa { 'ppa:mapnik/boost':
    require => Apt::Key['A6729974D728D7BA84154F8E4F7B93595D50B6BA'],
    options => ''
  }

  ::apt::source { 'dl.hhvm.com-ubuntu-precise':
    location => 'http://dl.hhvm.com/ubuntu',
    release  => 'precise',
    repos    => 'main',
    key      => {
      'id'     => '0x5a16e7281be7a449',
      'server' => 'hkp://keyserver.ubuntu.com:80',
    },
  }

}
