class puphpet::python::params
  inherits ::puphpet::params
{

  # config file could contain no versions key
  $versions = array_true($puphpet::params::hiera['python'], 'versions') ? {
    true    => $puphpet::params::hiera['python']['versions'],
    default => { }
  }

  # config file could contain no packages key
  $packages = array_true($puphpet::params::hiera['python'], 'packages') ? {
    true    => $puphpet::params::hiera['python']['packages'],
    default => { }
  }

  $setup_tools_url = 'https://bootstrap.pypa.io/ez_setup.py'
  $setup_tools_download = '/.puphpet-stuff/ez_setup.py'

}
