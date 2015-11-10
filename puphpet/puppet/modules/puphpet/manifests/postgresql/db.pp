# This depends on puppetlabs-postgresql: https://github.com/puppetlabs/puppetlabs-postgresql.git

define puphpet::postgresql::db (
  $dbname,
  $user,
  $password,
  $encoding   = $postgresql::server::encoding,
  $locale     = $postgresql::server::locale,
  $grant      = 'ALL',
  $tablespace = undef,
  $template   = 'template0',
  $istemplate = false,
  $owner      = undef,
  $sql_file   = false
) {

  if ! value_true($dbname) or ! value_true($user)
    or ! value_true($password)
  {
    fail('PostgreSQL DB requires that name, user, password and grant be set.')
  }

  if ! defined(Postgresql::Server::Database[$dbname]) {
    postgresql::server::database { $dbname:
      encoding   => $encoding,
      tablespace => $tablespace,
      template   => $template,
      locale     => $locale,
      istemplate => $istemplate,
      owner      => $owner,
    }
  }

  if ! defined(Postgresql::Server::Role[$user]) {
    postgresql::server::role { $user:
      password_hash => postgresql_password($user, $password),
    }
  }

  $grant_string = "GRANT ${user} - ${grant} - ${dbname}"

  if ! defined(Postgresql::Server::Database_grant[$grant_string]) {
    postgresql::server::database_grant { $grant_string:
      privilege => $grant,
      db        => $dbname,
      role      => $user,
    }
  }

  if($tablespace != undef
    and defined(Postgresql::Server::Tablespace[$tablespace]))
  {
    Postgresql::Server::Tablespace[$tablespace]
      -> Postgresql::Server::Database[$dbname]
  }

  if $sql_file {
    $table = "${dbname}.*"

    exec{ "${dbname}-import":
      command     => "sudo -u postgres psql ${dbname} < ${sql_file}",
      logoutput   => true,
      refreshonly => true,
      require     => Postgresql::Server::Database_grant[$grant_string],
      onlyif      => "test -f ${sql_file}",
      subscribe   => Postgresql::Server::Database[$dbname],
    }
  }

}
