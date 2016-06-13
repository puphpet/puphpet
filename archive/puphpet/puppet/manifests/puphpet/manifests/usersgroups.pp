class puphpet::usersgroups {

  include ::puphpet::params

  $users_groups = $puphpet::params::hiera['users_groups']

  Group <| |>
  -> User <| |>

  # config file could contain no groups key
  $groups = array_true($users_groups, 'groups') ? {
    true    => $users_groups['groups'],
    default => { }
  }

  each( $groups ) |$key, $group| {
    if ! defined(Group[$group]) {
      group { $group:
        ensure => present
      }
    }
  }

  # config file could contain no users key
  $users = array_true($users_groups, 'users') ? {
    true    => $users_groups['users'],
    default => { }
  }

  each( $users ) |$key, $user_group| {
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
