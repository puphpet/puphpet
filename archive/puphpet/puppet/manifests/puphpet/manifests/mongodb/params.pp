class puphpet::mongodb::params
 inherits puphpet::params
{

  # The GUI does not choose a version by default
  $global_settings = array_true($puphpet::params::hiera['mongodb'], 'global') ? {
    true    => $puphpet::params::hiera['mongodb']['global'],
    default => { }
  }

  $merged_globals = merge({
    'manage_package_repo' => true,
    'version'             => $::osfamily ? {
      'debian' => '2.6.11',
      'redhat' => '2.6.11-1',
    },
  }, $global_settings)

}
