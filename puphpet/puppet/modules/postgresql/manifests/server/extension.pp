# Activate an extension on a postgresql database
define postgresql::server::extension (
  $database,
  $ensure = 'present',
  $package_name = undef,
  $package_ensure = undef,
) {
  case $ensure {
    'present': {
      $command = "CREATE EXTENSION ${name}"
      $unless_comp = '='
      $package_require = undef
      $package_before = Postgresql_psql["Add ${title} extension to ${database}"]
    }

    'absent': {
      $command = "DROP EXTENSION ${name}"
      $unless_comp = '!='
      $package_require = Postgresql_psql["Add ${title} extension to ${database}"]
      $package_before = undef
    }

    default: {
      fail("Unknown value for ensure '${ensure}'.")
    }
  }

  postgresql_psql {"Add ${title} extension to ${database}":
    db      => $database,
    command => $command,
    unless  => "SELECT t.count FROM (SELECT count(extname) FROM pg_extension WHERE extname = '${name}') as t WHERE t.count ${unless_comp} 1",
    require => Postgresql::Server::Database[$database],
  }

  if $package_name {
    $_package_ensure = $package_ensure ? {
      undef   => $ensure,
      default => $package_ensure,
    }

    package { "Postgresql extension ${title}":
      ensure  => $_package_ensure,
      name    => $package_name,
      tag     => 'postgresql',
      require => $package_require,
      before  => $package_before,
    }
  }
}
