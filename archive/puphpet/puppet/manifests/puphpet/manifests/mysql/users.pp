define puphpet::mysql::users (
  $users
) {

  include ::puphpet::mysql::params

  each( $users ) |$key, $user| {
    # if no host passed with username, default to localhost
    if '@' in $user['name'] {
      $name = $user['name']
    } else {
      $name = "${user['name']}@localhost"
    }

    # force to_string to convert possible ints
    $password_hash = mysql_password(to_string($user['password']))

    $merged = delete(merge($user, {
      ensure          => 'present',
      'password_hash' => $password_hash,
    }), ['name', 'password'])

    create_resources( mysql_user, { "${name}" => $merged })
  }

}
