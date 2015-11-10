class puphpet_usersgroups (
  $users_groups
) {

  Group <| |>
  -> User <| |>

  each( $users_groups['groups'] ) |$key, $group| {
    if ! defined(Group[$group]) {
      group { $group:
        ensure => present
      }
    }
  }

  each( $users_groups['users'] ) |$key, $user_group| {
    $ug_array = split($user_group, ':')

    $user = $ug_array[0]

    if count($ug_array) > 1 {
      $groups = difference($ug_array, [$user])

      each( $groups ) |$key, $group| {
        if ! defined(Group[$group]) {
          group { $group:
            ensure => present
          }
        }
      }
    } else {
      $groups = []
    }

    if ! defined(User[$user]) {
      user { $user:
        ensure     => present,
        shell      => '/bin/bash',
        home       => "/home/${user}",
        managehome => true,
        groups     => $groups,
      }
    }
  }

}
