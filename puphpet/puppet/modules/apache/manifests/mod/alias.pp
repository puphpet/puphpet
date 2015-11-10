class apache::mod::alias(
  $apache_version = $apache::apache_version,
  $icons_options  = 'Indexes MultiViews',
) {
  $ver24 = versioncmp($apache_version, '2.4') >= 0

  $icons_path = $::osfamily ? {
    'debian'  => '/usr/share/apache2/icons',
    'redhat'  => $ver24 ? {
      true    => '/usr/share/httpd/icons',
      default => '/var/www/icons',
    },
    'freebsd' => '/usr/local/www/apache24/icons',
    'gentoo'  => '/usr/share/apache2/icons',
  }
  apache::mod { 'alias': }
  # Template uses $icons_path
  file { 'alias.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/alias.conf",
    content => template('apache/mod/alias.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
