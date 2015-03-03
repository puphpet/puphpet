if $ruby_values == undef { $ruby_values = hiera_hash('ruby', false) }

include puphpet::params

User <| title == $::ssh_username |> {
  groups +> 'rvm'
}

if hash_key_true($ruby_values, 'versions')
  and count($ruby_values['versions']) > 0
{
  puphpet::ruby::dotfile { 'do': }

  create_resources(puphpet::ruby::install, $ruby_values['versions'])
}
