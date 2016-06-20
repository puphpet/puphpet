class puphpet::apache::install
  inherits puphpet::apache::params
{

  include ::apache::params

  $apache = $puphpet::params::hiera['apache']

  if ! defined(Puphpet::Firewall::Port['80']) {
    ::puphpet::firewall::port { '80': }
  }

  if ! defined(Puphpet::Firewall::Port['443']) {
    ::puphpet::firewall::port { '443': }
  }

  $www_root      = $puphpet::apache::params::www_root
  $webroot_group = $puphpet::apache::params::webroot_group

  # centos 2.4 installation creates webroot automatically,
  # requiring us to manually set owner and permissions via exec
  exec { 'Create apache webroot':
    command => "mkdir -p ${www_root} && \
                chown root:${webroot_group} ${www_root} && \
                chmod 775 ${www_root} && \
                touch /.puphpet-stuff/apache-webroot-created",
    creates => '/.puphpet-stuff/apache-webroot-created',
    require => [
      Group[$webroot_group],
      Class['apache']
    ],
  }

  $index_file  = "${puphpet::apache::params::default_vhost_dir}/index.html"
  $source_file = "${puphpet::params::puphpet_manifest_dir}/files/webserver_landing.html"

  exec { "Set ${index_file} contents":
    command => "cat ${source_file} > ${index_file} && \
                chmod 644 ${index_file} && \
                chown root ${index_file} && \
                chgrp ${puphpet::apache::params::webroot_group} ${index_file} && \
                touch /.puphpet-stuff/default_vhost_index_file_set",
    returns => [0, 1],
    creates => '/.puphpet-stuff/default_vhost_index_file_set',
    require => Exec['Create apache webroot'],
  }

  if $::osfamily == 'debian' {
    file { $puphpet::apache::params::ssl_mutex_dir:
      ensure  => directory,
      group   => $puphpet::apache::params::webroot_group,
      mode    => '0775',
      require => Class['apache'],
      notify  => Service[$::apache::params::service_name],
    }
  }

  if $puphpet::apache::params::package_version == '2.4' {
    include ::puphpet::apache::repo
  }

  $settings = delete(merge($puphpet::params::hiera['apache']['settings'], {
    'apache_name'    => $puphpet::apache::params::package_name,
    'default_vhost'  => false,
    'mpm_module'     => 'worker',
    'conf_template'  => $::apache::params::conf_template,
    'sendfile'       => $puphpet::apache::params::sendfile,
    'apache_version' => $puphpet::apache::params::package_version
  }), 'version')

  create_resources('class', { 'apache' => $settings })

  puphpet::apache::modules { 'from puphpet::apache::install': }
  include ::puphpet::apache::ssl::snakeoil
  puphpet::apache::vhosts { 'from puphpet::apache::install': }

}
