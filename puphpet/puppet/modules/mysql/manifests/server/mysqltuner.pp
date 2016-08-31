#
class mysql::server::mysqltuner(
  $ensure  = 'present',
  $version = 'v1.3.0',
  $source  = undef,
) {

  if $source {
    $_version = $source
    $_source  = $source
  } else {
    $_version = $version
    $_source  = "https://github.com/major/MySQLTuner-perl/raw/${version}/mysqltuner.pl"
  }

  if $ensure == 'present' {
    class { 'staging': }
    staging::file { "mysqltuner-${_version}":
      source => $_source,
    }
    file { '/usr/local/bin/mysqltuner':
      ensure => $ensure,
      mode   => '0550',
      source => "${::staging::path}/mysql/mysqltuner-${_version}",
    }
  } else {
    file { '/usr/local/bin/mysqltuner':
      ensure => $ensure,
    }
  }
}
