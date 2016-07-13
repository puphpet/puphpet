# == Define Resource Type: puphpet::rabbitmq::users
#
define puphpet::rabbitmq::users (
  $users = $::puphpet::rabbitmq::params::users
){

  include ::puphpet::rabbitmq::params

  each( $users ) |$key, $user| {
    $username = $user['name']
    $is_admin = array_true($user, 'admin') ? {
      true    => true,
      default => false
    }

    $merged = delete(merge($user, {
      'admin' => $is_admin
    }), ['name', 'permissions'])

    create_resources(rabbitmq_user, { "${username}" => $merged })

    # config file could contain no user.permissions
    $permissions = array_true($user, 'permissions') ? {
      true    => $user['permissions'],
      default => { }
    }

    each($permissions) |$pkey, $permission| {
      $host = $permission['host']
      $permission_merged = delete($permission, 'host')

      create_resources(rabbitmq_user_permissions, {
        "${username}@${host}" => $permission_merged
      })
    }
  }

}
