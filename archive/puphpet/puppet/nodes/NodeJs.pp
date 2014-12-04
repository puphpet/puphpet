if $nodejs_values == undef { $nodejs_values = hiera_hash('nodejs', false) }

include puphpet::params

if hash_key_equals($nodejs_values, 'install', 1) {
  include puphpet::nodejs

  if is_array($nodejs_values['npm_packages']) and count($nodejs_values['npm_packages']) > 0 {
    each( $nodejs_values['npm_packages'] ) |$package| {
        $npm_array = split($package, '@')

        if count($npm_array) == 2 {
          $npm_ensure = $npm_array[1]
        } else {
          $npm_ensure = present
        }

      if ! defined(Package[$npm_array[0]]) {
        package { $npm_array[0]:
          ensure   => $npm_ensure,
          provider => npm,
        }
      }
    }
  }
}
