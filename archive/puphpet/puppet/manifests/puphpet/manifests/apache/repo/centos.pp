class puphpet::apache::repo::centos {

  if ! defined(Class['Puphpet::Server::Centos_ius']) {
    class { '::puphpet::server::centos_ius':
      before => Class['apache'],
    }
  }

}
