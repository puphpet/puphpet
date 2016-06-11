# This depends on puppetlabs-puppet-mysql: https://github.com/puppetlabs/puppetlabs-mysql

define puphpet::mysql::db (
  $dbname,
  $user,
  $password,
  $host,
  $grant    = [],
  $sql_file = false
) {
  if ! value_true($dbname) or ! value_true($password) or ! value_true($host) {
    fail( 'DB requires that name, password and host be set. Please check your settings!' )
  }

  include ::mysql::params

  if ! defined(Mysql_database[$dbname]) {
    $db_resource = {
      ensure   => present,
      charset  => 'utf8',
      collate  => 'utf8_general_ci',
      provider => 'mysql',
      require  => [
        Class['::mysql::server'],
        Class['::mysql::client']
      ],
    }
    ensure_resource('mysql_database', $dbname, $db_resource)
  }

  if ! defined(Mysql_user[$user]) {
    $user_resource = {
      ensure        => present,
      password_hash => mysql_password($password),
      provider      => 'mysql',
      require       => Class['::mysql::server'],
    }
    ensure_resource('mysql_user', "${user}@${host}", $user_resource)
  }

  $table = "${dbname}.*"

  if ! defined(Mysql_grant["${user}@${host}/${table}"]) {
    mysql_grant { "${user}@${host}/${table}":
      privileges => $grant,
      provider   => 'mysql',
      user       => "${user}@${host}",
      table      => $table,
      require    => [
        Mysql_database[$dbname],
        Mysql_user["${user}@${host}"],
        Class['::mysql::server']
      ],
    }
  }

  if $sql_file {
    exec{ "${dbname}-import":
      command     => "/usr/bin/mysql ${dbname} < ${sql_file}",
      onlyif      => "test -f ${sql_file}",
      logoutput   => true,
      environment => "HOME=${::root_home}",
      refreshonly => true,
      require     => Mysql_grant["${user}@${host}/${table}"],
      subscribe   => Mysql_database[$dbname],
    }
  }

}
