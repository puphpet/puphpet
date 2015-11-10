#
class mysql::server::install {

  if $mysql::server::package_manage {

    package { 'mysql-server':
      ensure          => $mysql::server::package_ensure,
      install_options => $mysql::server::install_options,
      name            => $mysql::server::package_name,
    }

    # Build the initial databases.
    $mysqluser = $mysql::server::options['mysqld']['user']
    $datadir = $mysql::server::options['mysqld']['datadir']
    $basedir = $mysql::server::options['mysqld']['basedir']
    $config_file = $mysql::server::config_file

    if $mysql::server::manage_config_file {
      $install_db_args = "--basedir=${basedir} --defaults-extra-file=${config_file} --datadir=${datadir} --user=${mysqluser}"
    } else {
      $install_db_args = "--basedir=${basedir} --datadir=${datadir} --user=${mysqluser}"
    }

    exec { 'mysql_install_db':
      command   => "mysql_install_db ${install_db_args}",
      creates   => "${datadir}/mysql",
      logoutput => on_failure,
      path      => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
      require   => Package['mysql-server'],
    }

    if $mysql::server::restart {
      Exec['mysql_install_db'] {
        notify => Class['mysql::server::service'],
      }
    }
  }

}
