# PRIVATE CLASS: do not call directly
class postgresql::server::config {
  $ip_mask_deny_postgres_user = $postgresql::server::ip_mask_deny_postgres_user
  $ip_mask_allow_all_users    = $postgresql::server::ip_mask_allow_all_users
  $listen_addresses           = $postgresql::server::listen_addresses
  $port                       = $postgresql::server::port
  $ipv4acls                   = $postgresql::server::ipv4acls
  $ipv6acls                   = $postgresql::server::ipv6acls
  $pg_hba_conf_path           = $postgresql::server::pg_hba_conf_path
  $pg_ident_conf_path         = $postgresql::server::pg_ident_conf_path
  $postgresql_conf_path       = $postgresql::server::postgresql_conf_path
  $pg_hba_conf_defaults       = $postgresql::server::pg_hba_conf_defaults
  $user                       = $postgresql::server::user
  $group                      = $postgresql::server::group
  $version                    = $postgresql::server::_version
  $manage_pg_hba_conf         = $postgresql::server::manage_pg_hba_conf
  $manage_pg_ident_conf       = $postgresql::server::manage_pg_ident_conf
  $datadir                    = $postgresql::server::datadir

  if ($manage_pg_hba_conf == true) {
    # Prepare the main pg_hba file
    concat { $pg_hba_conf_path:
      owner  => $user,
      group  => $group,
      mode   => '0640',
      warn   => true,
      notify => Class['postgresql::server::reload'],
    }

    if $pg_hba_conf_defaults {
      Postgresql::Server::Pg_hba_rule {
        database => 'all',
        user => 'all',
      }

      # Lets setup the base rules
      $local_auth_option = $version ? {
        '8.1'   => 'sameuser',
        default => undef,
      }
      postgresql::server::pg_hba_rule { 'local access as postgres user':
        type        => 'local',
        user        => $user,
        auth_method => 'ident',
        auth_option => $local_auth_option,
        order       => '001',
      }
      postgresql::server::pg_hba_rule { 'local access to database with same name':
        type        => 'local',
        auth_method => 'ident',
        auth_option => $local_auth_option,
        order       => '002',
      }
      postgresql::server::pg_hba_rule { 'allow localhost TCP access to postgresql user':
        type        => 'host',
        user        => $user,
        address     => '127.0.0.1/32',
        auth_method => 'md5',
        order       => '003',
      }
      postgresql::server::pg_hba_rule { 'deny access to postgresql user':
        type        => 'host',
        user        => $user,
        address     => $ip_mask_deny_postgres_user,
        auth_method => 'reject',
        order       => '004',
      }

      # ipv4acls are passed as an array of rule strings, here we transform
      # them into a resources hash, and pass the result to create_resources
      $ipv4acl_resources = postgresql_acls_to_resources_hash($ipv4acls,
      'ipv4acls', 10)
      create_resources('postgresql::server::pg_hba_rule', $ipv4acl_resources)

      postgresql::server::pg_hba_rule { 'allow access to all users':
        type        => 'host',
        address     => $ip_mask_allow_all_users,
        auth_method => 'md5',
        order       => '100',
      }
      postgresql::server::pg_hba_rule { 'allow access to ipv6 localhost':
        type        => 'host',
        address     => '::1/128',
        auth_method => 'md5',
        order       => '101',
      }

      # ipv6acls are passed as an array of rule strings, here we transform
      # them into a resources hash, and pass the result to create_resources
      $ipv6acl_resources = postgresql_acls_to_resources_hash($ipv6acls,
      'ipv6acls', 102)
      create_resources('postgresql::server::pg_hba_rule', $ipv6acl_resources)
    }
  }

  # We must set a "listen_addresses" line in the postgresql.conf if we
  # want to allow any connections from remote hosts.
  postgresql::server::config_entry { 'listen_addresses':
    value => $listen_addresses,
  }
  postgresql::server::config_entry { 'port':
    value => $port,
  }
  postgresql::server::config_entry { 'data_directory':
    value => $datadir,
  }

  # RedHat-based systems hardcode some PG* variables in the init script, and need to be overriden
  # in /etc/sysconfig/pgsql/postgresql. Create a blank file so we can manage it with augeas later.
  if ($::osfamily == 'RedHat') and ($::operatingsystemrelease !~ /^7/) and ($::operatingsystem != 'Fedora') {
    file { '/etc/sysconfig/pgsql/postgresql':
      ensure  => present,
      replace => false,
    }

    # The init script from the packages of the postgresql.org repository
    # sources an alternate sysconfig file.
    # I. e. /etc/sysconfig/pgsql/postgresql-9.3 for PostgreSQL 9.3
    # Link to the sysconfig file set by this puppet module
    file { "/etc/sysconfig/pgsql/postgresql-${version}":
      ensure  => link,
      target  => '/etc/sysconfig/pgsql/postgresql',
      require => File[ '/etc/sysconfig/pgsql/postgresql' ],
    }

  }


  if ($manage_pg_ident_conf == true) {
    concat { $pg_ident_conf_path:
      owner  => $user,
      group  => $group,
      force  => true, # do not crash if there is no pg_ident_rules
      mode   => '0640',
      warn   => true,
      notify => Class['postgresql::server::reload'],
    }
  }

  if $::osfamily == 'RedHat' {
    if $::operatingsystemrelease =~ /^7/ or $::operatingsystem == 'Fedora' {
      file { 'systemd-override':
        ensure  => present,
        path    => '/etc/systemd/system/postgresql.service',
        owner   => root,
        group   => root,
        content => template('postgresql/systemd-override.erb'),
        notify  => [ Exec['restart-systemd'], Class['postgresql::server::service'] ],
        before  => Class['postgresql::server::reload'],
      }
      exec { 'restart-systemd':
        command     => 'systemctl daemon-reload',
        refreshonly => true,
        path        => '/bin:/usr/bin:/usr/local/bin'
      }
    }
  }
}
