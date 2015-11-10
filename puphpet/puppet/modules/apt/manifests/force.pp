# force.pp
# force a package from a specific release

define apt::force(
  $release     = false,
  $version     = false,
  $timeout     = 300,
  $cfg_files   = 'none',
  $cfg_missing = false,
) {

  validate_re($cfg_files, ['^new', '^old', '^unchanged', '^none'])
  validate_bool($cfg_missing)

  $provider = $apt::params::provider

  $version_string = $version ? {
    false   => undef,
    default => "=${version}",
  }

  $release_string = $release ? {
    false   => undef,
    default => "-t ${release}",
  }

  case $cfg_files {
    'new':           { $config_files = '-o Dpkg::Options::="--force-confnew"' }
    'old':           { $config_files = '-o Dpkg::Options::="--force-confold"' }
    'unchanged':     { $config_files = '-o Dpkg::Options::="--force-confdef"' }
    'none', default: { $config_files = '' }
  }

  case $cfg_missing {
    true:           { $config_missing = '-o Dpkg::Options::="--force-confmiss"' }
    false, default: { $config_missing = '' }
  }

  if $version == false {
    if $release == false {
      $install_check = "/usr/bin/dpkg -s ${name} | grep -q 'Status: install'"
    } else {
      # If installed version and candidate version differ, this check returns 1 (false).
      $install_check = "/usr/bin/test \$(/usr/bin/apt-cache policy -t ${release} ${name} | /bin/grep -E 'Installed|Candidate' | /usr/bin/uniq -s 14 | /usr/bin/wc -l) -eq 1"
    }
  } else {
    if $release == false {
      $install_check = "/usr/bin/dpkg -s ${name} | grep -q 'Version: ${version}'"
    } else {
      $install_check = "/usr/bin/apt-cache policy -t ${release} ${name} | /bin/grep -q 'Installed: ${version}'"
    }
  }

  exec { "${provider} -y ${config_files} ${config_missing} ${release_string} install ${name}${version_string}":
    unless      => $install_check,
    environment => ['LC_ALL=C', 'LANG=C'],
    logoutput   => 'on_failure',
    timeout     => $timeout,
  }
}
