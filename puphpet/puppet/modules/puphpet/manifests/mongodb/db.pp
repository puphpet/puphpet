# This depends on puppetlabs/mongodb: https://github.com/puppetlabs/puppetlabs-mongodb
# Creates MongoDB database and user
define puphpet::mongodb::db (
  $dbname,
  $user,
  $password,
  $roles     = ['dbAdmin', 'readWrite', 'userAdmin'],
  $tries     = 10,
) {
  if ! value_true($name) or ! value_true($password) {
    fail( 'MongoDB requires that name and password be set.' )
  }

  if ! defined(Mongodb_database[$dbname]) {
    mongodb_database { $dbname:
      ensure  => present,
      tries   => $tries,
      require => Class['mongodb::server'],
    }
  }

  $hash = mongodb_password($user, $password)

  if ! defined(Mongodb_user[$user]) {
    mongodb_user { $user:
      ensure        => present,
      password_hash => $hash,
      database      => $dbname,
      roles         => $roles,
      require       => Mongodb_database[$dbname],
    }
  }
}
