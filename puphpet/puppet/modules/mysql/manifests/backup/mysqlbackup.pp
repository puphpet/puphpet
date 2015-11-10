# See README.me for usage.
class mysql::backup::mysqlbackup (
  $backupuser,
  $backuppassword,
  $backupdir,
  $backupdirmode = '0700',
  $backupdirowner = 'root',
  $backupdirgroup = 'root',
  $backupcompress = true,
  $backuprotate = 30,
  $ignore_events = true,
  $delete_before_dump = false,
  $backupdatabases = [],
  $file_per_database = false,
  $ensure = 'present',
  $time = ['23', '5'],
  $postscript = false,
  $execpath   = '/usr/bin:/usr/sbin:/bin:/sbin',
) {

  mysql_user { "${backupuser}@localhost":
    ensure        => $ensure,
    password_hash => mysql_password($backuppassword),
    provider      => 'mysql',
    require       => Class['mysql::server::root_password'],
  }

  package { 'meb':
    ensure    => $ensure,
  }

  # http://dev.mysql.com/doc/mysql-enterprise-backup/3.11/en/mysqlbackup.privileges.html
  mysql_grant { "${backupuser}@localhost/*.*":
    ensure     => $ensure,
    user       => "${backupuser}@localhost",
    table      => '*.*',
    privileges => [ 'RELOAD', 'SUPER', 'REPLICATION CLIENT' ],
    require    => Mysql_user["${backupuser}@localhost"],
  }

  mysql_grant { "${backupuser}@localhost/mysql.backup_progress":
    ensure     => $ensure,
    user       => "${backupuser}@localhost",
    table      => 'mysql.backup_progress',
    privileges => [ 'CREATE', 'INSERT', 'DROP', 'UPDATE' ],
    require    => Mysql_user["${backupuser}@localhost"],
  }

  mysql_grant { "${backupuser}@localhost/mysql.backup_history":
    ensure     => $ensure,
    user       => "${backupuser}@localhost",
    table      => 'mysql.backup_history',
    privileges => [ 'CREATE', 'INSERT', 'SELECT', 'DROP', 'UPDATE' ],
    require    => Mysql_user["${backupuser}@localhost"],
  }

  cron { 'mysqlbackup-weekly':
    ensure  => $ensure,
    command => 'mysqlbackup backup',
    user    => 'root',
    hour    => $time[0],
    minute  => $time[1],
    weekday => 0,
    require => Package['meb'],
  }

  cron { 'mysqlbackup-daily':
    ensure  => $ensure,
    command => 'mysqlbackup --incremental backup',
    user    => 'root',
    hour    => $time[0],
    minute  => $time[1],
    weekday => 1-6,
    require => Package['meb'],
  }

  $default_options = {
    'mysqlbackup' => {
      'backup-dir'             => $backupdir,
      'with-timestamp'         => true,
      'incremental_base'       => 'history:last_backup',
      'incremental_backup_dir' => $backupdir,
      'user'                   => $backupuser,
      'password'               => $backuppassword,
    }
  }
  $options = mysql_deepmerge($default_options, $mysql::server::override_options)

  file { 'mysqlbackup-config-file':
    path    => '/etc/mysql/conf.d/meb.cnf',
    content => template('mysql/meb.cnf.erb'),
    mode    => '0600',
  }

  file { 'mysqlbackupdir':
    ensure => 'directory',
    path   => $backupdir,
    mode   => $backupdirmode,
    owner  => $backupdirowner,
    group  => $backupdirgroup,
  }

}
