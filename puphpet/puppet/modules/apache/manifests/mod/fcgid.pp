class apache::mod::fcgid(
  $options = {},
) {
  if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == '7' {
    $loadfile_name = 'unixd_fcgid.load'
  } else {
    $loadfile_name = undef
  }

  ::apache::mod { 'fcgid':
    loadfile_name => $loadfile_name
  }

  # Template uses:
  # - $options
  file { 'fcgid.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/fcgid.conf",
    content => template('apache/mod/fcgid.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
