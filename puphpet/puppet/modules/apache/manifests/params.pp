# Class: apache::params
#
# This class manages Apache parameters
#
# Parameters:
# - The $user that Apache runs as
# - The $group that Apache runs as
# - The $apache_name is the name of the package and service on the relevant
#   distribution
# - The $php_package is the name of the package that provided PHP
# - The $ssl_package is the name of the Apache SSL package
# - The $apache_dev is the name of the Apache development libraries package
# - The $conf_contents is the contents of the Apache configuration file
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class apache::params inherits ::apache::version {
  if($::fqdn) {
    $servername = $::fqdn
  } else {
    $servername = $::hostname
  }

  # The default error log level
  $log_level = 'warn'
  $use_optional_includes = false

  if $::operatingsystem == 'Ubuntu' and $::lsbdistrelease == '10.04' {
    $verify_command = '/usr/sbin/apache2ctl -t'
  } else {
    $verify_command = '/usr/sbin/apachectl -t'
  }
  if $::osfamily == 'RedHat' or $::operatingsystem == 'amazon' {
    $user                 = 'apache'
    $group                = 'apache'
    $root_group           = 'root'
    $apache_name          = 'httpd'
    $service_name         = 'httpd'
    $httpd_dir            = '/etc/httpd'
    $server_root          = '/etc/httpd'
    $conf_dir             = "${httpd_dir}/conf"
    $confd_dir            = "${httpd_dir}/conf.d"
    $mod_dir              = "${httpd_dir}/conf.d"
    $mod_enable_dir       = undef
    $vhost_dir            = "${httpd_dir}/conf.d"
    $vhost_enable_dir     = undef
    $conf_file            = 'httpd.conf'
    $ports_file           = "${conf_dir}/ports.conf"
    $logroot              = '/var/log/httpd'
    $logroot_mode         = undef
    $lib_path             = 'modules'
    $mpm_module           = 'prefork'
    $dev_packages         = 'httpd-devel'
    $default_ssl_cert     = '/etc/pki/tls/certs/localhost.crt'
    $default_ssl_key      = '/etc/pki/tls/private/localhost.key'
    $ssl_certs_dir        = '/etc/pki/tls/certs'
    $passenger_conf_file  = 'passenger_extra.conf'
    $passenger_conf_package_file = 'passenger.conf'
    $passenger_root       = undef
    $passenger_ruby       = undef
    $passenger_default_ruby = undef
    $suphp_addhandler     = 'php5-script'
    $suphp_engine         = 'off'
    $suphp_configpath     = undef
    # NOTE: The module for Shibboleth is not available to RH/CentOS without an additional repository. http://wiki.aaf.edu.au/tech-info/sp-install-guide
    # NOTE: The auth_cas module isn't available to RH/CentOS without enabling EPEL.
    $mod_packages         = {
      'auth_cas'    => 'mod_auth_cas',
      'auth_kerb'   => 'mod_auth_kerb',
      'authnz_ldap' => $::apache::version::distrelease ? {
        '7'     => 'mod_ldap',
        default => 'mod_authz_ldap',
      },
      'fastcgi'     => 'mod_fastcgi',
      'fcgid'       => 'mod_fcgid',
      'ldap'        => $::apache::version::distrelease ? {
        '7'     => 'mod_ldap',
        default => undef,
      },
      'pagespeed'   => 'mod-pagespeed-stable',
      'passenger'   => 'mod_passenger',
      'perl'        => 'mod_perl',
      'php5'        => $::apache::version::distrelease ? {
        '5'     => 'php53',
        default => 'php',
      },
      'proxy_html'  => 'mod_proxy_html',
      'python'      => 'mod_python',
      'security'    => 'mod_security',
      'shibboleth'  => 'shibboleth',
      'ssl'         => 'mod_ssl',
      'wsgi'        => 'mod_wsgi',
      'dav_svn'     => 'mod_dav_svn',
      'suphp'       => 'mod_suphp',
      'xsendfile'   => 'mod_xsendfile',
      'nss'         => 'mod_nss',
      'shib2'       => 'shibboleth',
    }
    $mod_libs             = {
      'php5' => 'libphp5.so',
      'nss'  => 'libmodnss.so',
    }
    $conf_template        = 'apache/httpd.conf.erb'
    $keepalive            = 'Off'
    $keepalive_timeout    = 15
    $max_keepalive_requests = 100
    $fastcgi_lib_path     = undef
    $mime_support_package = 'mailcap'
    $mime_types_config    = '/etc/mime.types'
    $docroot              = '/var/www/html'
    $error_documents_path = $::apache::version::distrelease ? {
      '7'     => '/usr/share/httpd/error',
      default => '/var/www/error'
    }
    if $::osfamily == 'RedHat' {
      $wsgi_socket_prefix = '/var/run/wsgi'
    } else {
      $wsgi_socket_prefix = undef
    }
    $cas_cookie_path      = '/var/cache/mod_auth_cas/'
    $modsec_crs_package   = 'mod_security_crs'
    $modsec_crs_path      = '/usr/lib/modsecurity.d'
    $modsec_dir           = '/etc/httpd/modsecurity.d'
    $modsec_default_rules = [
      'base_rules/modsecurity_35_bad_robots.data',
      'base_rules/modsecurity_35_scanners.data',
      'base_rules/modsecurity_40_generic_attacks.data',
      'base_rules/modsecurity_41_sql_injection_attacks.data',
      'base_rules/modsecurity_50_outbound.data',
      'base_rules/modsecurity_50_outbound_malware.data',
      'base_rules/modsecurity_crs_20_protocol_violations.conf',
      'base_rules/modsecurity_crs_21_protocol_anomalies.conf',
      'base_rules/modsecurity_crs_23_request_limits.conf',
      'base_rules/modsecurity_crs_30_http_policy.conf',
      'base_rules/modsecurity_crs_35_bad_robots.conf',
      'base_rules/modsecurity_crs_40_generic_attacks.conf',
      'base_rules/modsecurity_crs_41_sql_injection_attacks.conf',
      'base_rules/modsecurity_crs_41_xss_attacks.conf',
      'base_rules/modsecurity_crs_42_tight_security.conf',
      'base_rules/modsecurity_crs_45_trojans.conf',
      'base_rules/modsecurity_crs_47_common_exceptions.conf',
      'base_rules/modsecurity_crs_49_inbound_blocking.conf',
      'base_rules/modsecurity_crs_50_outbound.conf',
      'base_rules/modsecurity_crs_59_outbound_blocking.conf',
      'base_rules/modsecurity_crs_60_correlation.conf'
    ]
  } elsif $::osfamily == 'Debian' {
    $user                = 'www-data'
    $group               = 'www-data'
    $root_group          = 'root'
    $apache_name         = 'apache2'
    $service_name        = 'apache2'
    $httpd_dir           = '/etc/apache2'
    $server_root         = '/etc/apache2'
    $conf_dir            = $httpd_dir
    $confd_dir           = "${httpd_dir}/conf.d"
    $mod_dir             = "${httpd_dir}/mods-available"
    $mod_enable_dir      = "${httpd_dir}/mods-enabled"
    $vhost_dir           = "${httpd_dir}/sites-available"
    $vhost_enable_dir    = "${httpd_dir}/sites-enabled"
    $conf_file           = 'apache2.conf'
    $ports_file          = "${conf_dir}/ports.conf"
    $logroot             = '/var/log/apache2'
    $logroot_mode        = undef
    $lib_path            = '/usr/lib/apache2/modules'
    $mpm_module          = 'worker'
    $default_ssl_cert    = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
    $default_ssl_key     = '/etc/ssl/private/ssl-cert-snakeoil.key'
    $ssl_certs_dir       = '/etc/ssl/certs'
    $suphp_addhandler    = 'x-httpd-php'
    $suphp_engine        = 'off'
    $suphp_configpath    = '/etc/php5/apache2'
    $mod_packages        = {
      'auth_cas'    => 'libapache2-mod-auth-cas',
      'auth_kerb'   => 'libapache2-mod-auth-kerb',
      'dav_svn'     => 'libapache2-svn',
      'fastcgi'     => 'libapache2-mod-fastcgi',
      'fcgid'       => 'libapache2-mod-fcgid',
      'nss'         => 'libapache2-mod-nss',
      'pagespeed'   => 'mod-pagespeed-stable',
      'passenger'   => 'libapache2-mod-passenger',
      'perl'        => 'libapache2-mod-perl2',
      'php5'        => 'libapache2-mod-php5',
      'proxy_html'  => 'libapache2-mod-proxy-html',
      'python'      => 'libapache2-mod-python',
      'rpaf'        => 'libapache2-mod-rpaf',
      'security'    => 'libapache2-modsecurity',
      'suphp'       => 'libapache2-mod-suphp',
      'wsgi'        => 'libapache2-mod-wsgi',
      'xsendfile'   => 'libapache2-mod-xsendfile',
      'shib2'       => 'libapache2-mod-shib2',
    }
    $mod_libs             = {
      'php5' => 'libphp5.so',
    }
    $conf_template          = 'apache/httpd.conf.erb'
    $keepalive              = 'Off'
    $keepalive_timeout      = 15
    $max_keepalive_requests = 100
    $fastcgi_lib_path       = '/var/lib/apache2/fastcgi'
    $mime_support_package = 'mime-support'
    $mime_types_config    = '/etc/mime.types'
    $docroot              = '/var/www'
    $cas_cookie_path      = '/var/cache/apache2/mod_auth_cas/'
    $modsec_crs_package   = 'modsecurity-crs'
    $modsec_crs_path      = '/usr/share/modsecurity-crs'
    $modsec_dir           = '/etc/modsecurity'
    $modsec_default_rules = [
      'base_rules/modsecurity_35_bad_robots.data',
      'base_rules/modsecurity_35_scanners.data',
      'base_rules/modsecurity_40_generic_attacks.data',
      'base_rules/modsecurity_41_sql_injection_attacks.data',
      'base_rules/modsecurity_50_outbound.data',
      'base_rules/modsecurity_50_outbound_malware.data',
      'base_rules/modsecurity_crs_20_protocol_violations.conf',
      'base_rules/modsecurity_crs_21_protocol_anomalies.conf',
      'base_rules/modsecurity_crs_23_request_limits.conf',
      'base_rules/modsecurity_crs_30_http_policy.conf',
      'base_rules/modsecurity_crs_35_bad_robots.conf',
      'base_rules/modsecurity_crs_40_generic_attacks.conf',
      'base_rules/modsecurity_crs_41_sql_injection_attacks.conf',
      'base_rules/modsecurity_crs_41_xss_attacks.conf',
      'base_rules/modsecurity_crs_42_tight_security.conf',
      'base_rules/modsecurity_crs_45_trojans.conf',
      'base_rules/modsecurity_crs_47_common_exceptions.conf',
      'base_rules/modsecurity_crs_49_inbound_blocking.conf',
      'base_rules/modsecurity_crs_50_outbound.conf',
      'base_rules/modsecurity_crs_59_outbound_blocking.conf',
      'base_rules/modsecurity_crs_60_correlation.conf'
    ]
    $error_documents_path = '/usr/share/apache2/error'
    if ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '13.10') >= 0) or ($::operatingsystem == 'Debian' and versioncmp($::operatingsystemrelease, '8') >= 0) {
      $dev_packages        = ['libaprutil1-dev', 'libapr1-dev', 'apache2-dev']
    } else {
      $dev_packages        = ['libaprutil1-dev', 'libapr1-dev', 'apache2-prefork-dev']
    }

    #
    # Passenger-specific settings
    #

    $passenger_conf_file         = 'passenger.conf'
    $passenger_conf_package_file = undef

    case $::operatingsystem {
      'Ubuntu': {
        case $::lsbdistrelease {
          '12.04': {
            $passenger_root         = '/usr'
            $passenger_ruby         = '/usr/bin/ruby'
            $passenger_default_ruby = undef
          }
          '14.04': {
            $passenger_root         = '/usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini'
            $passenger_ruby         = undef
            $passenger_default_ruby = '/usr/bin/ruby'
          }
          default: {
            # The following settings may or may not work on Ubuntu releases not
            # supported by this module.
            $passenger_root         = '/usr'
            $passenger_ruby         = '/usr/bin/ruby'
            $passenger_default_ruby = undef
          }
        }
      }
      'Debian': {
        case $::lsbdistcodename {
          'wheezy': {
            $passenger_root         = '/usr'
            $passenger_ruby         = '/usr/bin/ruby'
            $passenger_default_ruby = undef
          }
          'jessie': {
            $passenger_root         = '/usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini'
            $passenger_ruby         = undef
            $passenger_default_ruby = '/usr/bin/ruby'
          }
          default: {
            # The following settings may or may not work on Debian releases not
            # supported by this module.
            $passenger_root         = '/usr'
            $passenger_ruby         = '/usr/bin/ruby'
            $passenger_default_ruby = undef
          }
        }
      }
    }
    $wsgi_socket_prefix = undef
  } elsif $::osfamily == 'FreeBSD' {
    $user             = 'www'
    $group            = 'www'
    $root_group       = 'wheel'
    $apache_name      = 'apache24'
    $service_name     = 'apache24'
    $httpd_dir        = '/usr/local/etc/apache24'
    $server_root      = '/usr/local'
    $conf_dir         = $httpd_dir
    $confd_dir        = "${httpd_dir}/Includes"
    $mod_dir          = "${httpd_dir}/Modules"
    $mod_enable_dir   = undef
    $vhost_dir        = "${httpd_dir}/Vhosts"
    $vhost_enable_dir = undef
    $conf_file        = 'httpd.conf'
    $ports_file       = "${conf_dir}/ports.conf"
    $logroot          = '/var/log/apache24'
    $logroot_mode     = undef
    $lib_path         = '/usr/local/libexec/apache24'
    $mpm_module       = 'prefork'
    $dev_packages     = undef
    $default_ssl_cert = '/usr/local/etc/apache24/server.crt'
    $default_ssl_key  = '/usr/local/etc/apache24/server.key'
    $ssl_certs_dir    = '/usr/local/etc/apache24'
    $passenger_conf_file = 'passenger.conf'
    $passenger_conf_package_file = undef
    $passenger_root   = '/usr/local/lib/ruby/gems/2.0/gems/passenger-4.0.58'
    $passenger_ruby   = '/usr/local/bin/ruby'
    $passenger_default_ruby = undef
    $suphp_addhandler = 'php5-script'
    $suphp_engine     = 'off'
    $suphp_configpath = undef
    $mod_packages     = {
      # NOTE: I list here only modules that are not included in www/apache24
      # NOTE: 'passenger' needs to enable APACHE_SUPPORT in make config
      # NOTE: 'php' needs to enable APACHE option in make config
      # NOTE: 'dav_svn' needs to enable MOD_DAV_SVN make config
      # NOTE: not sure where the shibboleth should come from
      'auth_kerb'  => 'www/mod_auth_kerb2',
      'fcgid'      => 'www/mod_fcgid',
      'passenger'  => 'www/rubygem-passenger',
      'perl'       => 'www/mod_perl2',
      'php5'       => 'www/mod_php5',
      'proxy_html' => 'www/mod_proxy_html',
      'python'     => 'www/mod_python3',
      'wsgi'       => 'www/mod_wsgi',
      'dav_svn'    => 'devel/subversion',
      'xsendfile'  => 'www/mod_xsendfile',
      'rpaf'       => 'www/mod_rpaf2',
      'shib2'      => 'security/shibboleth2-sp',
    }
    $mod_libs         = {
      'php5' => 'libphp5.so',
    }
    $conf_template        = 'apache/httpd.conf.erb'
    $keepalive            = 'Off'
    $keepalive_timeout    = 15
    $max_keepalive_requests = 100
    $fastcgi_lib_path     = undef # TODO: revisit
    $mime_support_package = 'misc/mime-support'
    $mime_types_config    = '/usr/local/etc/mime.types'
    $wsgi_socket_prefix   = undef
    $docroot              = '/usr/local/www/apache24/data'
    $error_documents_path = '/usr/local/www/apache24/error'
  } elsif $::osfamily == 'Gentoo' {
    $user             = 'apache'
    $group            = 'apache'
    $root_group       = 'wheel'
    $apache_name      = 'www-servers/apache'
    $service_name     = 'apache2'
    $httpd_dir        = '/etc/apache2'
    $server_root      = '/var/www'
    $conf_dir         = $httpd_dir
    $confd_dir        = "${httpd_dir}/conf.d"
    $mod_dir          = "${httpd_dir}/modules.d"
    $mod_enable_dir   = undef
    $vhost_dir        = "${httpd_dir}/vhosts.d"
    $vhost_enable_dir = undef
    $conf_file        = 'httpd.conf'
    $ports_file       = "${conf_dir}/ports.conf"
    $logroot          = '/var/log/apache2'
    $logroot_mode     = undef
    $lib_path         = '/usr/lib/apache2/modules'
    $mpm_module       = 'prefork'
    $dev_packages     = undef
    $default_ssl_cert = '/etc/ssl/apache2/server.crt'
    $default_ssl_key  = '/etc/ssl/apache2/server.key'
    $ssl_certs_dir    = '/etc/ssl/apache2'
    $passenger_root   = '/usr'
    $passenger_ruby   = '/usr/bin/ruby'
    $passenger_conf_file = 'passenger.conf'
    $passenger_conf_package_file = undef
    $passenger_default_ruby = undef
    $suphp_addhandler = 'x-httpd-php'
    $suphp_engine     = 'off'
    $suphp_configpath = '/etc/php5/apache2'
    $mod_packages     = {
      # NOTE: I list here only modules that are not included in www-servers/apache
      'auth_kerb'  => 'www-apache/mod_auth_kerb',
      'fcgid'      => 'www-apache/mod_fcgid',
      'passenger'  => 'www-apache/passenger',
      'perl'       => 'www-apache/mod_perl',
      'php5'       => 'dev-lang/php',
      'proxy_html' => 'www-apache/mod_proxy_html',
      'proxy_fcgi' => 'www-apache/mod_proxy_fcgi',
      'python'     => 'www-apache/mod_python',
      'wsgi'       => 'www-apache/mod_wsgi',
      'dav_svn'    => 'dev-vcs/subversion',
      'xsendfile'  => 'www-apache/mod_xsendfile',
      'rpaf'       => 'www-apache/mod_rpaf',
      'xml2enc'    => 'www-apache/mod_xml2enc',
    }
    $mod_libs         = {
      'php5' => 'libphp5.so',
    }
    $conf_template        = 'apache/httpd.conf.erb'
    $keepalive            = 'Off'
    $keepalive_timeout    = 15
    $max_keepalive_requests = 100
    $fastcgi_lib_path     = undef # TODO: revisit
    $mime_support_package = 'app-misc/mime-types'
    $mime_types_config    = '/etc/mime.types'
    $wsgi_socket_prefix   = undef
    $docroot              = '/var/www/localhost/htdocs'
    $error_documents_path = '/usr/share/apache2/error'
  } else {
    fail("Class['apache::params']: Unsupported osfamily: ${::osfamily}")
  }
}
