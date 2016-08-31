class puphpet_nodejs (
  $nodejs
) {

  include puphpet::nodejs

  each( $nodejs['npm_packages'] ) |$package| {
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
