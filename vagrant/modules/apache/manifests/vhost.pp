# = Define: apache::vhost
#
# This class manages Apache Virtual Hosts configuration files
#
# == Parameters:
# [*port*]
#   The port to configure the host on
#
# [*docroot*]
#   The VirtualHost DocumentRoot
#
# [*docroot_create*]
#   If the specified directory has to be created. Default: false
#
# [*ssl*]
#   Set to true to enable SSL for this Virtual Host
#
# [*template*]
#   Specify a custom template to use instead of the default one
#   The value will be used in content => template($template)
#
# [*priority*]
#   The priority of the VirtualHost, lower values are evaluated first
#   Set to '' to edit default apache value
#
# [*serveraliases*]
#   An optional list of space separated ServerAliases
#
# [*server_admin*]
#   Server admin email address
#
# [*server_name*]
#   An optional way to directly set server name
#   False mean, that servername is not present in generated config file
#
# == Example:
#  apache::vhost { 'site.name.fqdn':
#    docroot  => '/path/to/docroot',
#  }
#
#  apache::vhost { 'mysite':
#    docroot  => '/path/to/docroot',
#    template => 'myproject/apache/mysite.conf',
#  }
#
define apache::vhost (
  $server_admin   = '',
  $server_name    = '',
  $serveraliases  = '',
  $docroot        = '',
  $docroot_create = false,
  $docroot_owner  = 'root',
  $docroot_group  = 'root',
  $port           = '80',
  $ssl            = false,
  $template       = 'apache/virtualhost/vhost.conf.erb',
  $priority       = '50',
  $env_variables  = '',
  $enable         = true ) {

  $ensure = bool2ensure($enable)
  $bool_docroot_create = any2bool($docroot_create)

  $real_docroot = $docroot ? {
    ''      => "${apache::data_dir}/${name}",
    default => $docroot,
  }

  $server_name_value = $server_name ? {
    ''      => $name,
    default => $server_name,
  }

  # Server admin email
  if $server_admin != '' {
    $server_admin_email = "${server_admin}"
  } elsif ($name != 'default') and ($name != 'default-ssl') {
    $server_admin_email = "webmaster@${name}"
  } else {
    $server_admin_email = "webmaster@localhost"
  }

  # Config file path
  if $priority != '' {
    $config_file_path = "${apache::vdir}/${priority}-${name}.conf"
  } elsif ($name != 'default') and ($name != 'default-ssl') {
    $config_file_path = "${apache::vdir}/${name}.conf"
  } else {
    $config_file_path = "${apache::vdir}/${name}"
  }

  # Config file enable path
  if $priority != '' {
    $config_file_enable_path = "${apache::config_dir}/sites-enabled/${priority}-${name}.conf"
  } elsif ($name != 'default') and ($name != 'default-ssl') {
    $config_file_enable_path = "${apache::config_dir}/sites-enabled/${name}.conf"
  } else {
    $config_file_enable_path = "${apache::config_dir}/sites-enabled/000-${name}"
  }

  include apache

  file { "${config_file_path}":
    ensure  => $ensure,
    content => template($template),
    mode    => $apache::config_file_mode,
    owner   => $apache::config_file_owner,
    group   => $apache::config_file_group,
    require => Package['apache'],
    notify  => $apache::manage_service_autorestart,
  }

  # Some OS specific settings:
  # On Debian/Ubuntu manages sites-enabled
  case $::operatingsystem {
    ubuntu,debian,mint: {
      file { "ApacheVHostEnabled_$name":
        ensure  => $enable ? {
          true  => "${config_file_path}",
          false => absent,
        },
        path    => "${config_file_enable_path}",
        require => Package['apache'],
      }
    }
    redhat,centos,scientific,fedora: {
      include apache::redhat
    }
    default: { }
  }

  if $bool_docroot_create == true {
    file { $real_docroot:
      ensure  => directory,
      owner   => $docroot_owner,
      group   => $docroot_group,
      mode    => '0775',
      require => Package['apache'],
    }
  }
}
