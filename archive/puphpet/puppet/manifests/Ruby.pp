class puphpet_ruby (
  $ruby
) {

  include '::gnupg'

  Class['::rvm']
  -> Puphpet::Ruby::Dotfile <| |>
  -> Puphpet::Ruby::Install <| |>

  class { '::rvm': }

  if ! defined(Group['rvm']) {
    group { 'rvm':
      ensure => present
    }
  }

  User <| title == $::ssh_username |> {
    groups +> 'rvm'
  }

  if array_true($ruby, 'versions') and count($ruby['versions']) > 0 {
    puphpet::ruby::dotfile { 'do': }

    create_resources(puphpet::ruby::install, $ruby['versions'])
  }

}
