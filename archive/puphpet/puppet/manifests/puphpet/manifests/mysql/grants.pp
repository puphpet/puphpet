define puphpet::mysql::grants (
  $grants
) {

  include ::puphpet::mysql::params

  each( $grants ) |$key, $grant| {
    # if no host passed with username, default to localhost
    if '@' in $grant['user'] {
      $user = $grant['user']
    } else {
      $user = "${grant['user']}@localhost"
    }

    $table = $grant['table']

    $name = "${user}/${table}"

    $options = array_true($grant, 'options') ? {
      true    => $grant['options'],
      default => ['GRANT']
    }

    $merged = merge($grant, {
      ensure    => 'present',
      'user'    => $user,
      'options' => $options,
    })

    create_resources( mysql_grant, { "${name}" => $merged })
  }

}
