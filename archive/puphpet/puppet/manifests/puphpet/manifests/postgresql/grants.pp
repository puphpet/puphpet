define puphpet::postgresql::grants (
  $grants
) {

  include ::puphpet::postgresql::params

  each( $grants ) |$key, $grant| {
    $merged = merge($grant, {
      'privilege' => join($grant['privilege'], ','),
    })

    create_resources( postgresql::server::database_grant, {
      "${grant['role']}@${grant['db']}" => $merged,
    })
  }

}
