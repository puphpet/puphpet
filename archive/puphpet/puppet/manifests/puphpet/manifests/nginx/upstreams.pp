define puphpet::nginx::upstreams (
  $upstreams
) {

  include ::puphpet::nginx::params

  each( $upstreams ) |$key, $upstream| {
    $name   = $upstream['name']
    $merged = delete($upstream, ['name'])

    create_resources(nginx::resource::upstream, {
      "${name}" => $merged
    })

    # upstream hash could contain no members key
    $members = array_true($upstream, 'members') ? {
      true    => $upstream['members'],
      default => { }
    }

    each( $members ) |$key, $member| {
      $member_array = $package_array = split($member, ':')

      if count($member_array) == 2
        and ! defined(Puphpet::Firewall::Port["${member_array[1]}"])
      {
        puphpet::firewall::port { "${member_array[1]}": }
      }
    }
  }

}
