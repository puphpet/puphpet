# PRIVATE CLASS: do not call directly
class postgresql::server::service {
  $service_ensure   = $postgresql::server::service_ensure
  $service_enable   = $postgresql::server::service_enable
  $service_manage   = $postgresql::server::service_manage
  $service_name     = $postgresql::server::service_name
  $service_provider = $postgresql::server::service_provider
  $service_status   = $postgresql::server::service_status
  $user             = $postgresql::server::user
  $port             = $postgresql::server::port
  $default_database = $postgresql::server::default_database

  anchor { 'postgresql::server::service::begin': }

  if $service_manage {

    service { 'postgresqld':
      ensure    => $service_ensure,
      enable    => $service_enable,
      name      => $service_name,
      provider  => $service_provider,
      hasstatus => true,
      status    => $service_status,
    }

    if $service_ensure == 'running' {
      # This blocks the class before continuing if chained correctly, making
      # sure the service really is 'up' before continuing.
      #
      # Without it, we may continue doing more work before the database is
      # prepared leading to a nasty race condition.
      postgresql::validate_db_connection { 'validate_service_is_running':
        run_as          => $user,
        database_name   => $default_database,
        database_port   => $port,
        sleep           => 1,
        tries           => 60,
        create_db_first => false,
        require         => Service['postgresqld'],
        before          => Anchor['postgresql::server::service::end']
      }
    }
  }

  anchor { 'postgresql::server::service::end': }
}
