# See README.md for details.
define mysql::db (
  $user,
  $password,
  $dbname         = $name,
  $charset        = 'utf8',
  $collate        = 'utf8_general_ci',
  $host           = 'localhost',
  $grant          = 'ALL',
  $sql            = undef,
  $enforce_sql    = false,
  $ensure         = 'present',
  $import_timeout = 300,
) {
  #input validation
  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")
  $table = "${dbname}.*"

  if !(is_array($sql) or is_string($sql)) {
    fail('$sql must be either a string or an array.')
  }

  $sql_inputs = join([$sql], ' ')

  include '::mysql::client'

  anchor{"mysql::db_${name}::begin": }->
  Class['::mysql::client']->
  anchor{"mysql::db_${name}::end": }

  $db_resource = {
    ensure   => $ensure,
    charset  => $charset,
    collate  => $collate,
    provider => 'mysql',
    require  => [ Class['mysql::server'], Class['mysql::client'] ],
  }
  ensure_resource('mysql_database', $dbname, $db_resource)

  $user_resource = {
    ensure        => $ensure,
    password_hash => mysql_password($password),
    provider      => 'mysql',
    require       => Class['mysql::server'],
  }
  ensure_resource('mysql_user', "${user}@${host}", $user_resource)

  if $ensure == 'present' {
    mysql_grant { "${user}@${host}/${table}":
      privileges => $grant,
      provider   => 'mysql',
      user       => "${user}@${host}",
      table      => $table,
      require    => [Mysql_database[$dbname], Mysql_user["${user}@${host}"], Class['mysql::server'] ],
    }

    $refresh = ! $enforce_sql

    if $sql {
      exec{ "${dbname}-import":
        command     => "cat ${sql_inputs} | mysql ${dbname}",
        logoutput   => true,
        environment => "HOME=${::root_home}",
        refreshonly => $refresh,
        path        => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
        require     => Mysql_grant["${user}@${host}/${table}"],
        subscribe   => Mysql_database[$dbname],
        timeout     => $import_timeout,
      }
    }
  }
}
