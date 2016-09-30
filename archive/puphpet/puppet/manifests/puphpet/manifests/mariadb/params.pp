class puphpet::mariadb::params
 inherits puphpet::params
{

  include ::mysql::params

  $settings = delete(deep_merge({
    'package_name'     => $package_server_name,
    'restart'          => true,
    'override_options' => deep_merge($::mysql::params::default_options, {
      'mysqld' => {
        'tmpdir' => $::mysql::params::tmpdir,
      }
    }),
    'service_name'     => 'mysql',
  }, $hiera['mariadb']['settings']), ['version', 'root_password'])

  $mariadb = deep_merge(
    $hiera['mariadb'],
    {'settings' => $settings}
  )

  $user = $settings['override_options']['mysqld']['user']

  $version = '10.0'

  $package_server_name = $::osfamily ? {
    'Debian' => 'mariadb-server',
    'Redhat' => 'MariaDB-server',
  }

  $package_client_name = $::osfamily ? {
    'Debian' => 'mariadb-client',
    'Redhat' => 'MariaDB-client',
  }

}
