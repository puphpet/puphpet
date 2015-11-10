define puphpet::ini (
  $php_version,
  $webserver,
  $ini_filename = 'zzzz_custom.ini',
  $entry,
  $value        = '',
  $ensure       = present
) {

  warning('puphpet::ini is deprecated; please use puphpet::php::ini')

  ::puphpet::php::ini { $name:
    php_version  => $php_version,
    webserver    => $webserver,
    ini_filename => $ini_filename,
    entry        => $entry,
    value        => $value,
    ensure       => $ensure,
  }
}
