class puphpet::apache::repo::centos (
  $url = 'http://repo.puphpet.com/centos/httpd24/httpd-2.4.10-RPM-full.x86_64.tgz'
){

  $save_to    = '/.puphpet-stuff/httpd-2.4.tgz'
  $extract_to = '/.puphpet-stuff/httpd-2.4'

  $cmd = "wget --quiet --tries=5 --connect-timeout=10 -O '${save_to}' ${url}"

  exec { "download ${url}":
    creates => $save_to,
    command => $cmd,
    timeout => 3600,
    path    => '/usr/bin',
  } ->
  exec { "untar ${save_to}":
    creates => $extract_to,
    command => "mkdir -p ${extract_to} && \
                tar xzf '${save_to}' -C ${extract_to} --strip-components=1",
    cwd     => '/.puphpet-stuff',
    path    => '/bin',
  } ->
  exec { 'install httpd-2.4.10':
    creates => '/etc/httpd',
    command => 'yum -y localinstall * --skip-broken',
    cwd     => $extract_to,
    path    => '/usr/bin',
  }

  exec { 'rm /etc/httpd/conf.d/systemd.load':
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    onlyif  => 'test -f /etc/httpd/conf.d/systemd.load',
    require => Class['apache'],
    notify  => Service['httpd'],
  }

}
