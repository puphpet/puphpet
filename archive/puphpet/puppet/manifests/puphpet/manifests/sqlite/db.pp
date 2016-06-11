# Creates database, adds user
# If requested, imports DB
define puphpet::sqlite::db (
  $owner,
  $group = 0,
  $sql_file = false
) {

  if $db_name == '' or $owner == '' {
    fail('SQLite requires that name and owner be set.')
  }

  $group_real = value_true($group) ? {
    true    => $group,
    default => 0
  }

  $location = "/var/lib/sqlite/${db_name}.db"

  file { $location:
    ensure  => present,
    owner   => $owner,
    group   => $group_real,
    mode    => '0775',
    require => File['/var/lib/sqlite'],
    notify  => Exec["create_${db_name}_db"],
  }

  exec { "create_${db_name}_db":
    command     => "sqlite3 ${location}",
    path        => '/usr/bin:/usr/local/bin',
    refreshonly => true,
  }

  if $sql_file {
    $sqlite_db = "sqlite3 /var/lib/sqlite/${db_name}.db"

    exec{ "${db_name}-import":
      command     => "cat ${sql_file} | sudo ${sqlite_db}",
      logoutput   => true,
      refreshonly => true,
      require     => File[$location],
      onlyif      => "test -f ${sql_file}"
    }
  }

}
