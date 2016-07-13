define puphpet::python::pyenv (
  $versions = $puphpet::python::params::versions,
) {

  include ::puphpet::python::params

  each( $versions ) |$key, $version| {
    $install_virtualenv = value_true($version['virtualenv']) ? {
      true    => true,
      default => false,
    }

    pyenv_python { $version['version']:
      ensure     => present,
      keep       => true,
      virtualenv => $install_virtualenv,
      require    => Class['::pyenv'],
      before     => Anchor['puphpet::python::end']
    } ->
    file { "python v${version['version']} symlink":
      ensure => link,
      path   => "/usr/bin/python${version['version']}",
      target => "/usr/local/pyenv/versions/${version['version']}/bin/python",
    } ->
    file { "python v${version['version']} virtualenv symlink":
      ensure => link,
      path   => "/usr/bin/virtualenv-${version['version']}",
      target => "/usr/local/pyenv/versions/${version['version']}/bin/virtualenv",
    } ->
    file { "python v${version['version']} pip symlink":
      ensure => link,
      path   => "/usr/bin/pip-${version['version']}",
      target => "/usr/local/pyenv/versions/${version['version']}/bin/pip",
    } ->
    file { 'python pip symlink':
      ensure => link,
      path   => '/usr/bin/pip',
      target => "/usr/local/pyenv/versions/${version['version']}/bin/pip",
    }
  }

}
