define puphpet::postgresql::databases (
  $databases
) {

  include ::postgresql::params

  each( $databases ) |$key, $database| {
    $owner = array_true($database, 'owner') ? {
      true    => $database['owner'],
      default => $postgresql::server::user,
    }

    $merged = merge($database, {
      'owner' => $owner,
    })

    create_resources( postgresql::server::database, {
      "${owner}@${database['dbname']}" => $merged
    })
  }

}
