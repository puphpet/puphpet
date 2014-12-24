if $usersgroups_values == undef { $usersgroups_values = hiera_hash('users_groups', false) }

Group <| |> -> User <| |>

if count($usersgroups_values['groups']) > 0 {
  each( $usersgroups_values['groups'] ) |$key, $group| {
    if ! defined(Group[$group]) {
      group { $group:
        ensure => present
      }
    }
  }
}

if count($usersgroups_values['users']) > 0 {
  each( $usersgroups_values['users'] ) |$key, $user_group| {
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
        shell      => '/bin/bash',
        home       => "/home/${user}",
        managehome => true,
        ensure     => present,
        groups     => $groups,
      }
    }
  }
}
