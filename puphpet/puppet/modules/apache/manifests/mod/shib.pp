class apache::mod::shib (
  $suppress_warning = false,
) {

  if $::osfamily == 'RedHat' and ! $suppress_warning {
    warning('RedHat distributions do not have Apache mod_shib in their default package repositories.')
  }

  $mod_shib = 'shib2'

  apache::mod {$mod_shib:
    id => 'mod_shib',
  }

}