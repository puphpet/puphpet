define build::requires (
    $ensure = 'installed',
    $package
) {

    if defined( Package[$package] ) {
        debug("${package} already installed")
    } else {
        package { $package:
            ensure => $ensure
        }
    }
}
