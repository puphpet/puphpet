define puphpet::mariadb::databases (
  $databases
) {

  include ::puphpet::mariadb::params
  include ::puphpet::mysql::params

  each( $databases ) |$key, $database| {
    $name = $database['name']
    $sql  = $database['sql']

    $import_timeout = array_true($database, 'import_timeout') ? {
      true    => $database['import_timeout'],
      default => 300
    }

    $merged = delete(merge($database, {
      ensure => 'present',
    }), ['name', 'sql', 'import_timeout'])

    create_resources( mysql_database, { "${name}" => $merged })

    if $sql != '' {
      # Run import only on initial database creation
      $touch_file = "/.puphpet-stuff/db-import-${name}"

      exec{ "${name}-import":
        command     => "mysql ${name} < ${sql} && touch ${touch_file}",
        creates     => $touch_file,
        logoutput   => true,
        environment => "HOME=${::root_home}",
        path        => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
        timeout     => $import_timeout,
        require     => Mysql_database[$name]
      }
    }
  }

}
