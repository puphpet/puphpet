class puphpet_nvm (
  $nvm
) {

  class { 'nvm': }

  each( $nvm['users'] ) |$user| {
    nvm::install { $user: }

    each( $nvm['versions'] ) |$version| {
      nvm::node::install { "${version} for ${user}":
        user => $user,
        version => $version,
        require => Nvm::Install[$user]
      }
    }
  }
}
