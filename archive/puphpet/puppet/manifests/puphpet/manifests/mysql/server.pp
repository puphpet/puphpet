class puphpet::mysql::server (
  $settings
){

  include puphpet::mysql::params
  include ::mysql::params

  $true_settings_no_pw = delete(deep_merge({
    'package_name'     => $puphpet::mysql::params::server_package,
    'restart'          => true,
    'override_options' => deep_merge($::mysql::params::default_options, {
      'mysqld' => {
        'tmpdir' => $::mysql::params::tmpdir,
      }
    }),
    'install_options'  => $::osfamily ? {
      'Debian' => '--force-yes',
      default  => undef,
    },
    require            => Class['puphpet::mysql::repo'],
  }, $settings), ['version', 'root_password'])

  $true_settings = deep_merge({
    'root_password' => $puphpet::mysql::params::root_password
  }, $true_settings_no_pw)

  create_resources('class', {
    'mysql::server' => $true_settings
  })

}
