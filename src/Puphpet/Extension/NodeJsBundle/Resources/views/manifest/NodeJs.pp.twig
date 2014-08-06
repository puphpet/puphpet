if $nodejs_values == undef { $nodejs_values = hiera_hash('nodejs', false) }

include puphpet::params

if hash_key_equals($nodejs_values, 'install', 1) {
  include puphpet::nodejs

  if is_array($nodejs_values['npm_packages']) and count($nodejs_values['npm_packages']) > 0 {
    each( $nodejs_values['npm_packages'] ) |$package| {
      if ! defined(Package[$package]) {
        package { $package:
          ensure   => present,
          provider => npm,
        }
      }
    }
  }
}
