class puphpet::apache::params
  inherits ::puphpet::params
{

  include ::apache::params

  if array_true($puphpet::params::hiera['apache']['settings'], 'version')
    and $puphpet::params::hiera['apache']['settings']['version'] in ['2.2', '22', 2.2, 22]
  {
    $package_version = '2.2'

    $package_name = $::osfamily ? {
      'Debian' => $::apache::params::apache_name,
      'Redhat' => 'httpd'
    }

    $module_prefix = $::osfamily ? {
      'Debian' => 'mod',
      'Redhat' => 'mod'
    }

    $system_modules = []
  } else {
    $package_version = '2.4'

    $package_name = $::osfamily ? {
      'Debian' => $::apache::params::apache_name,
      'Redhat' => 'httpd24u'
    }

    $module_prefix = $::osfamily ? {
      'Debian' => 'mod',
      'Redhat' => 'mod24u'
    }

    $system_modules = $::osfamily ? {
      'Debian' => [],
      'Redhat' => [
        'httpd24u-filesystem',
        'httpd24-httpd-tools',
        'httpd24-mod_ldap',
        'httpd24-mod_proxy_html',
        'httpd24-mod_session',
      ]
    }
  }

  $www_root = $::osfamily ? {
    'Debian' => '/var/www',
    'Redhat' => '/var/www'
  }

  $default_vhost_dir = $::osfamily ? {
    'Debian' => '/var/www/html',
    'Redhat' => '/var/www/html'
  }

  $webroot_user  = 'www-data'
  $webroot_group = 'www-data'

  $sendfile = array_true($puphpet::params::hiera['apache']['settings'], 'sendfile') ? {
    true    => 'On',
    default => 'Off'
  }

  $mod_pagespeed_url = $::osfamily ? {
    'Debian' => $::architecture ? {
        'i386'   => 'https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_i386.deb',
        'amd64'  => 'https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb',
        'x86_64' => 'https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb'
      },
    'Redhat' => $::architecture ? {
        'i386'   => 'https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_i386.rpm',
        'amd64'  => 'https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_x86_64.rpm',
        'x86_64' => 'https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_x86_64.rpm'
      },
  }

  $mod_pagespeed_package = 'mod-pagespeed-stable'

  $ssl_cert_location = $::osfamily ? {
    'Debian' => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
    'Redhat' => '/etc/ssl/certs/ssl-cert-snakeoil'
  }

  $ssl_key_location = $::osfamily ? {
    'Debian' => '/etc/ssl/private/ssl-cert-snakeoil.key',
    'Redhat' => '/etc/ssl/certs/ssl-cert-snakeoil'
  }

  $ssl_ciphers = [
    'ECDHE-RSA-AES256-GCM-SHA384', 'ECDHE-RSA-AES128-GCM-SHA256',
    'DHE-RSA-AES256-GCM-SHA384', 'DHE-RSA-AES128-GCM-SHA256',
    'ECDHE-RSA-AES256-SHA384', 'ECDHE-RSA-AES128-SHA256', 'ECDHE-RSA-AES256-SHA',
    'ECDHE-RSA-AES128-SHA', 'DHE-RSA-AES256-SHA256', 'DHE-RSA-AES128-SHA256',
    'DHE-RSA-AES256-SHA', 'DHE-RSA-AES128-SHA', 'ECDHE-RSA-DES-CBC3-SHA',
    'EDH-RSA-DES-CBC3-SHA', 'AES256-GCM-SHA384', 'AES128-GCM-SHA256', 'AES256-SHA256',
    'AES128-SHA256', 'AES256-SHA', 'AES128-SHA', 'DES-CBC3-SHA',
    'HIGH', '!aNULL', '!eNULL', '!EXPORT', '!DES', '!MD5', '!PSK', '!RC4'
  ]

  $ssl_mutex_dir = '/var/run/apache2/ssl_mutex'

  if array_true($puphpet::params::hiera['php'], 'install')
    and ! ($puphpet::params::hiera['php']['settings']['version'] in ['5.3', '53'])
  {
    $php_engine    = true
    $php_fcgi_port = '9000'
  } elsif array_true($puphpet::params::hiera['hhvm'], 'install') {
    $php_engine    = true
    $php_fcgi_port = array_true($puphpet::params::hiera['hhvm']['server_ini'], 'hhvm.server.port') ? {
      true    => $puphpet::params::hiera['hhvm']['server_ini']['hhvm.server.port'],
      default => '9000'
    }
  } else {
    $php_engine    = false
  }

  $php_sethandler = $php_engine ? {
    true    => "proxy:fcgi://127.0.0.1:${php_fcgi_port}",
    default => 'default-handler'
  }

  if $php_engine {
    $default_vhost_directories = {'default' => {
      'provider'        => 'directory',
      'path'            => $default_vhost_dir,
      'options'         => ['Indexes', 'FollowSymlinks', 'MultiViews'],
      'allow_override'  => ['All'],
      'require'         => ['all granted'],
      'files_match'     => {'php_match' => {
        'provider'   => 'filesmatch',
        'path'       => '\.php$',
        'sethandler' => $php_sethandler,
      }},
      'custom_fragment' => '',
    }}
  } else {
    $default_vhost_directories = {'default' => {
      'provider'        => 'directory',
      'path'            => $default_vhost_dir,
      'options'         => ['Indexes', 'FollowSymlinks', 'MultiViews'],
      'allow_override'  => ['All'],
      'require'         => ['all granted'],
      'files_match'     => {},
      'custom_fragment' => '',
    }}
  }

  if array_true($puphpet::params::hiera['apache']['settings'], 'default_vhost') {
    $default_vhosts = {
      'default_vhost_80'  => {
        'servername'    => 'default',
        'docroot'       => $default_vhost_dir,
        'port'          => 80,
        'directories'   => $default_vhost_directories,
        'default_vhost' => true,
      },
      'default_vhost_443' => {
        'servername'    => 'default',
        'docroot'       => $default_vhost_dir,
        'port'          => 443,
        'directories'   => $default_vhost_directories,
        'default_vhost' => true,
        'ssl'           => 1,
      },
    }
  } else {
    $default_vhosts = {}
  }

  # config file could contain no modules key
  $modules = array_true($puphpet::params::hiera['apache'], 'modules') ? {
    true    => $puphpet::params::hiera['apache']['modules'],
    default => [ ],
  }

  # config file could contain no vhosts key
  $vhosts = array_true($puphpet::params::hiera['apache'], 'vhosts') ? {
    true    => merge(
      $puphpet::params::hiera['apache']['vhosts'],
      $puphpet::apache::params::default_vhosts
    ),
    default => $puphpet::apache::params::default_vhosts,
  }

}
