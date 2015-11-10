class apache::mod::cgi {
  case $::osfamily {
    'FreeBSD': {}
    default: {
      Class['::apache::mod::prefork'] -> Class['::apache::mod::cgi']
    }
  }

  ::apache::mod { 'cgi': }
}
