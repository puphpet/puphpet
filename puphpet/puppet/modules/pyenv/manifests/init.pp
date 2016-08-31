class pyenv(
  $ensure_repo           = 'present',
  $repo_location         = '/usr/local/pyenv',
  $repo_revision         = 'v0.4.0-20140404',
  $symlink_pyenv         = true,
  $symlink_path          = '/usr/local/bin',
  $manage_packages       = true,
  $ensure_packages       = 'latest',
  $python_build_packages = $::pyenv::params::python_build_packages,
) inherits ::pyenv::params {

  validate_absolute_path($repo_location)
  validate_re($ensure_repo, ['present', 'absent'])
  validate_string($repo_revision)
  validate_bool($symlink_pyenv)
  validate_absolute_path($symlink_path)
  validate_bool($manage_packages)
  validate_array($python_build_packages)

  vcsrepo { $repo_location:
    ensure   => $ensure_repo,
    owner    => 0,
    group    => 0,
    provider => 'git',
    source   => 'https://github.com/yyuu/pyenv.git',
    revision => $repo_revision,
  }

  if $symlink_path {
    file { "${symlink_path}/pyenv":
      target => "${repo_location}/bin/pyenv",
    }
  }

  if $manage_packages {
    if empty($python_build_packages) {
      warn('You have requested to install packages but
      $python_build_packages is empty')
    } else {
      package { $python_build_packages:
        ensure => $ensure_packages,
      }
    }
  }
}
