# = Define a git repository as a resource
#
# == Parameters:
#
# $source::     The URI to the source of the repository
#
# $path::       The path where the repository should be cloned to, fully qualified paths are recommended, and the $owner needs write permissions.
#
# $branch::     The branch to be checked out
#
# $git_tag::    The tag to be checked out
#
# $owner::      The user who should own the repository
#
# $update::     If this is true, puppet will revert local changes and pull remote changes when it runs.
#
# $bare::       If this is true, git will create a bare repository

define git::repo(
  $path,
  $source   = false,
  $branch   = undef,
  $git_tag  = undef,
  $owner    = 'root',
  $group    = 'root',
  $update   = false,
  $bare     = false
){

  require git
  require git::params

  validate_bool($bare, $update)

  if $branch {
    $real_branch = $branch
  } else {
    $real_branch = 'master'
  }

  if $source {
    $init_cmd = "${git::params::bin} clone -b ${real_branch} ${source} ${path} --recursive"
  } else {
    if $bare {
      $init_cmd = "${git::params::bin} init --bare ${target}"
    } else {
      $init_cmd = "${git::params::bin} init ${target}"
    }
  }

  $creates = $bare ? {
    true    => "${path}/objects",
    default => "${path}/.git",
  }

  exec {"git_repo_${name}":
    command   => $init_cmd,
    user      => $owner,
    creates   => $creates,
    require   => Package[$git::params::package],
    timeout   => 600,
    onlyif    => "/usr/bin/test ! -d ${path}/.git",
    logoutput => "on_failure",
  }

  # I think tagging works, but it's possible setting a tag and a branch will just fight.
  # It should change branches too...
  if $git_tag {
    exec {"git_${name}_co_tag":
      user    => $owner,
      cwd     => $path,
      command => "${git::params::bin} checkout ${git_tag}",
      unless  => "${git::params::bin} describe --tag|/bin/grep -P '${git_tag}'",
      require => Exec["git_repo_${name}"],
    }
  } elsif ! $bare {
    exec {"git_${name}_co_branch":
      user    => $owner,
      cwd     => $path,
      command => "${git::params::bin} checkout ${branch}",
      unless  => "${git::params::bin} branch|/bin/grep -P '\\* ${branch}'",
      require => Exec["git_repo_${name}"],
    }
    if $update {
      exec {"git_${name}_pull":
        user    => $owner,
        cwd     => $path,
        command => "${git::params::bin} reset --hard HEAD && ${git::params::bin} pull origin ${branch}",
        unless  => "${git::params::bin} diff origin --no-color --exit-code",
        require => Exec["git_repo_${name}"],
      }
    }
  }
}
