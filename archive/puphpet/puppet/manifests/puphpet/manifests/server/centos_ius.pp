class puphpet::server::centos_ius {

  $url = 'https://setup.ius.io/'
  $path = '/.puphpet-stuff/ius.sh'
  $cmd  = "wget --quiet --tries=5 --connect-timeout=10 -O '${path}' ${url}"

  exec { "download ${url}":
    creates => $path,
    command => $cmd,
    timeout => 3600,
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
  } ->
  file { $path:
    ensure => present,
    mode   => '+x',
  } ->
  exec { "${path} && touch /.puphpet-stuff/ius.sh-ran":
    creates => '/.puphpet-stuff/ius.sh-ran',
    timeout => 3600,
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

}
