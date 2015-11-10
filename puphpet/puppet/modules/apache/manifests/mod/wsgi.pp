class apache::mod::wsgi (
  $wsgi_socket_prefix = $::apache::params::wsgi_socket_prefix,
  $wsgi_python_path   = undef,
  $wsgi_python_home   = undef,
  $package_name       = undef,
  $mod_path           = undef,
){

  if ($package_name != undef and $mod_path == undef) or ($package_name == undef and $mod_path != undef) {
    fail('apache::mod::wsgi - both package_name and mod_path must be specified!')
  }

  if $package_name != undef {
    if $mod_path =~ /\// {
      $_mod_path = $mod_path
    } else {
      $_mod_path = "${::apache::params::lib_path}/${mod_path}"
    }
    ::apache::mod { 'wsgi':
      package => $package_name,
      path    => $_mod_path,
    }
  }
  else {
    ::apache::mod { 'wsgi': }
  }

  # Template uses:
  # - $wsgi_socket_prefix
  # - $wsgi_python_path
  # - $wsgi_python_home
  file {'wsgi.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/wsgi.conf",
    content => template('apache/mod/wsgi.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}

