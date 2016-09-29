class puphpet::postgresql::params
 inherits puphpet::params
{

  if empty($hiera['postgresql']['settings']['server']['postgres_password']) {
    fail( 'PostgreSQL requires choosing a root password.' )
  }

}
