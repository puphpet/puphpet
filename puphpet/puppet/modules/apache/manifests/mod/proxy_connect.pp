class apache::mod::proxy_connect (
  $apache_version  = $::apache::apache_version,
) {
  if versioncmp($apache_version, '2.4') >= 0 {
    Class['::apache::mod::proxy'] -> Class['::apache::mod::proxy_connect']
    ::apache::mod { 'proxy_connect': }
  }
}
