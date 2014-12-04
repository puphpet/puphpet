if $ruby_values == undef { $ruby_values = hiera_hash('ruby', false) }

include puphpet::params

if hash_key_true($ruby_values, 'versions') and count($ruby_values['versions']) > 0 {
  $rvm_has_default = false

  rvm_dotfile { 'do': }

  create_resources(install_ruby, $ruby_values['versions'])
}

define install_ruby (
  $version,
  $default = false,
  $bundler = false,
  $gems    = []
) {

  $default_true = value_true($default)
  $bundler_true = value_true($bundle)

  if value_true($version) {
    rvm_system_ruby { $version:
        default_use => $default_true,
        ensure      => present,
        require     => File_line['rvm_autoupdate_flag=0 >> ~/.rvmrc'],
    }

    if $bundler_true == true {
      $gems_merged = concat($gems, 'bundler')
    } else {
      $gems_merged = $gems
    }

    if count($gems_merged) > 0 {
      each( $gems_merged ) |$key, $gem| {
        $gem_array = split($gem, '@')

        if count($gem_array) == 2 {
          $gem_ensure = $gem_array[1]
        } else {
          $gem_ensure = present
        }

        rvm_gem { $gem_array[0]:
          name         => $gem_array[0],
          ruby_version => $version,
          ensure       => $gem_ensure,
          require      => Rvm_system_ruby[$version]
        }
      }
    }
  }

}

define rvm_dotfile {
  if $::ssh_username != 'root' {
    file { "/home/${::ssh_username}/.rvmrc":
      ensure => present,
      owner  => $::ssh_username,
      require => User[$::ssh_username]
    }
    file_line { 'rvm_autoupdate_flag=0 >> ~/.rvmrc':
      ensure  => present,
      line    => 'rvm_autoupdate_flag=0',
      path    => "/home/${::ssh_username}/.rvmrc",
      require => File["/home/${::ssh_username}/.rvmrc"],
    }
  }

  file { "/root/.rvmrc":
    ensure => present,
    owner  => 'root',
  }
  file_line { 'rvm_autoupdate_flag=0 >> /root/.rvmrc':
    ensure  => present,
    line    => 'rvm_autoupdate_flag=0',
    path    => "/root/.rvmrc",
    require => File["/root/.rvmrc"],
  }
}
