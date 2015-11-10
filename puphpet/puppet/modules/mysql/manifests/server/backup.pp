# See README.me for usage.
class mysql::server::backup (
  $backupuser         = undef,
  $backuppassword     = undef,
  $backupdir          = undef,
  $backupdirmode      = '0700',
  $backupdirowner     = 'root',
  $backupdirgroup     = 'root',
  $backupcompress     = true,
  $backuprotate       = 30,
  $ignore_events      = true,
  $delete_before_dump = false,
  $backupdatabases    = [],
  $file_per_database  = false,
  $ensure             = 'present',
  $time               = ['23', '5'],
  $postscript         = false,
  $execpath           = '/usr/bin:/usr/sbin:/bin:/sbin',
  $provider           = 'mysqldump',
) {

  create_resources('class', {
    "mysql::backup::${provider}" => {
      'backupuser'         => $backupuser,
      'backuppassword'     => $backuppassword,
      'backupdir'          => $backupdir,
      'backupdirmode'      => $backupdirmode,
      'backupdirowner'     => $backupdirowner,
      'backupdirgroup'     => $backupdirgroup,
      'backupcompress'     => $backupcompress,
      'backuprotate'       => $backuprotate,
      'ignore_events'      => $ignore_events,
      'delete_before_dump' => $delete_before_dump,
      'backupdatabases'    => $backupdatabases,
      'file_per_database'  => $file_per_database,
      'ensure'             => $ensure,
      'time'               => $time,
      'postscript'         => $postscript,
      'execpath'           => $execpath,
    }
  })

}
