# This depends on maestrodev/rvm: https://github.com/maestrodev/puppet-rvm
# Installs Ruby using RVM
define puphpet::ruby::install (
  $version,
  $default = false,
  $bundler = false,
  $gems    = []
) {

  $default_true = value_true($default)
  $bundler_true = value_true($bundler)

  if value_true($version) {
    rvm_system_ruby { $version:
        default_use => $default_true,
        ensure      => present,
        require     => File_line['rvm_autoupdate_flag=0 >> /root/.rvmrc'],
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
