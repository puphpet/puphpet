define apache::security::rule_link () {

  $parts = split($title, '/')
  $filename = $parts[-1]

  file { $filename:
    ensure  => 'link',
    path    => "${::apache::mod::security::modsec_dir}/activated_rules/${filename}",
    target  => "${::apache::params::modsec_crs_path}/${title}",
    require => File["${::apache::mod::security::modsec_dir}/activated_rules"],
    notify  => Class['apache::service'],
  }
}
