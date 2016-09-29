define puphpet::postgresql::users (
  $users
) {

  each( $users ) |$key, $user| {
    $superuser = array_true($user, 'superuser') ? {
      true    => true,
      default => false,
    }

    $no_superuser = delete(merge({
      'password_hash' => postgresql_password($user['username'], $user['password']),
      'login'         => true,
    }, $user), 'password')

    $merged = merge($no_superuser, {
      'superuser' => $superuser,
    })

    create_resources( postgresql::server::role, {
      "${merged['username']}" => $merged
    })
  }

}
