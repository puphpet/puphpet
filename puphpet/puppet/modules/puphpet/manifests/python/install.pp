# This depends on daenney/pyenv: https://github.com/puphpet/puppet-pyenv
# Installs Python using pyenv
define puphpet::python::install (
  $version,
  $virtualenv = false,
) {

  $install_virtualenv = value_true($virtualenv) ? {
    true    => true,
    default => false,
  }

  if value_true($version) {
    pyenv_python { $version:
      ensure     => present,
      keep       => true,
      virtualenv => $install_virtualenv,
      require    => Class['pyenv'],
    } ->
    file { "python v${version} symlink":
      ensure => link,
      path   => "/usr/bin/python${version}",
      target => "/usr/local/pyenv/versions/${version}/bin/python",
    } ->
    file { "python v${version} virtualenv symlink":
      ensure => link,
      path   => "/usr/bin/virtualenv-${version}",
      target => "/usr/local/pyenv/versions/${version}/bin/virtualenv",
    }
  }

}
