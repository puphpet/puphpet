class apache::mod::deflate (
  $types = [
    'text/html text/plain text/xml',
    'text/css',
    'application/x-javascript application/javascript application/ecmascript',
    'application/rss+xml'
  ],
  $notes = {
    'Input'  => 'instream',
    'Output' => 'outstream',
    'Ratio'  => 'ratio'
  }
) {
  ::apache::mod { 'deflate': }

  file { 'deflate.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/deflate.conf",
    content => template('apache/mod/deflate.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
