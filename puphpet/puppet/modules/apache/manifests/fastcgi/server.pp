define apache::fastcgi::server (
  $host          = '127.0.0.1:9000',
  $timeout       = 15,
  $flush         = false,
  $faux_path     = "/var/www/${name}.fcgi",
  $fcgi_alias    = "/${name}.fcgi",
  $file_type     = 'application/x-httpd-php'
) {
  include apache::mod::fastcgi

  Apache::Mod['fastcgi'] -> Apache::Fastcgi::Server[$title]

  file { "fastcgi-pool-${name}.conf":
    ensure  => present,
    path    => "${::apache::confd_dir}/fastcgi-pool-${name}.conf",
    owner   => 'root',
    group   => $::apache::params::root_group,
    mode    => '0644',
    content => template('apache/fastcgi/server.erb'),
    require => Exec["mkdir ${::apache::confd_dir}"],
    before  => File[$::apache::confd_dir],
    notify  => Class['apache::service'],
  }
}
