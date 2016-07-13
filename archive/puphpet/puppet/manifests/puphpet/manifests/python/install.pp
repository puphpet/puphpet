class puphpet::python::install
  inherits puphpet::python::params
{

  $python = $puphpet::params::hiera['python']

  anchor{ 'puphpet::python::init': }
  -> class { 'puphpet::python::pre': }
  -> class { '::pyenv':
    manage_packages => false,
  }

  puphpet::python::pyenv { 'from puphpet::python::install': }
  include ::puphpet::python::pip
  anchor{ 'puphpet::python::end': }

}
