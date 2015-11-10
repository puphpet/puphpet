# == Type: composer::project
#
# Installs a given project with composer create-project
#
# === Parameters
#
# Document parameters here.
#
# [*project_name*]
#   The project name as required by composer
#
# [*target_dir*]
#   The target dir that the project should be installed to
#
# [*version*]
#   The version of the composer project that should be checked out
#
# [*dev*]
#   Either ```curl``` or ```wget```.
#
# [*logoutput*]
#   If the output should be logged. Defaults to FALSE.
#
# [*tmp_path*]
#   Where the composer.phar file should be temporarily put.
#
# [*php_package*]
#   The Package name of the PHP CLI package.
#
# [*user*]
#   The user name to exec the composer commands as. Default is composer::user.
#
# [*working_dir*]
#   Use the given directory as working directory.
#
# === Authors
#
# Thomas Ploch <profiploch@gmail.com>
#
# === Copyright
#
# Copyright 2013 Thomas Ploch
#
define composer::project(
  $project_name,
  $target_dir,
  $version        = undef,
  $dev            = true,
  $prefer_source  = false,
  $stability      = 'dev',
  $repository_url = undef,
  $keep_vcs       = false,
  $tries          = 3,
  $timeout        = 1200,
  $user           = $composer::user,
  $working_dir    = undef,
) {
  require ::composer

  Exec {
    path        => "/bin:/usr/bin/:/sbin:/usr/sbin:${composer::target_dir}",
    environment => "COMPOSER_HOME=${composer::composer_home}",
    user        => $user,
  }

  $composer_path = "${composer::target_dir}/${composer::composer_file}"
  $stability_config = "--stability=${stability}"

  $exec_name    = "composer_create_project_${title}"
  $base_command = "${composer::php_bin} ${composer_path} ${stability_config}"

  $end_command  = "${project_name} ${target_dir}"

  $dev_arg = $dev ? {
    true    => '',
    default => ' --no-dev',
  }

  $vcs = $keep_vcs? {
    true    => ' --keep-vcs',
    default => '',
  }

  $repo = $repository_url? {
    undef   => '',
    default => " --repository-url=${repository_url}",
  }

  $pref_src = $prefer_source? {
    true    => ' --prefer-source',
    default => ''
  }

  $v = $version? {
    undef   => '',
    default => " ${version}",
  }

  $wdir = $working_dir? {
    undef   => '',
    default => " --working-dir=${working_dir}",
  }

  $concat_cmd = "${base_command}${dev_arg}${repo}${pref_src}${vcs}${wdir}"
  $or_rm_command = "${end_command}${v} || rm -rf ${target_dir}"

  exec { $exec_name:
    command => "${concat_cmd} --no-interaction create-project ${or_rm_command}",
    tries   => $tries,
    timeout => $timeout,
    creates => $target_dir,
    cwd     => $working_dir
  }
}
