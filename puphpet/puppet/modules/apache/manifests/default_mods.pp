class apache::default_mods (
  $all            = true,
  $mods           = undef,
  $apache_version = $::apache::apache_version
) {
  # These are modules required to run the default configuration.
  # They are not configurable at this time, so we just include
  # them to make sure it works.
  case $::osfamily {
    'redhat': {
      ::apache::mod { 'log_config': }
      if versioncmp($apache_version, '2.4') >= 0 {
        # Lets fork it
        # Do not try to load mod_systemd on RHEL/CentOS 6 SCL.
        if ( !($::osfamily == 'redhat' and versioncmp($::operatingsystemrelease, '7.0') == -1) and !($::operatingsystem == 'Amazon' and versioncmp($::operatingsystemrelease, '2014.09') <= 0  ) ) {
          ::apache::mod { 'systemd': }
        }
        ::apache::mod { 'unixd': }
      }
    }
    'freebsd': {
      ::apache::mod { 'log_config': }
      ::apache::mod { 'unixd': }
    }
    default: {}
  }
  case $::osfamily {
    'gentoo': {}
    default: {
      ::apache::mod { 'authz_host': }
    }
  }
  # The rest of the modules only get loaded if we want all modules enabled
  if $all {
    case $::osfamily {
      'debian': {
        include ::apache::mod::reqtimeout
        if versioncmp($apache_version, '2.4') >= 0 {
          ::apache::mod { 'authn_core': }
        }
      }
      'redhat': {
        include ::apache::mod::actions
        include ::apache::mod::cache
        include ::apache::mod::mime
        include ::apache::mod::mime_magic
        include ::apache::mod::rewrite
        include ::apache::mod::speling
        include ::apache::mod::suexec
        include ::apache::mod::version
        include ::apache::mod::vhost_alias
        ::apache::mod { 'auth_digest': }
        ::apache::mod { 'authn_anon': }
        ::apache::mod { 'authn_dbm': }
        ::apache::mod { 'authz_dbm': }
        ::apache::mod { 'authz_owner': }
        ::apache::mod { 'expires': }
        ::apache::mod { 'ext_filter': }
        ::apache::mod { 'include': }
        ::apache::mod { 'logio': }
        ::apache::mod { 'substitute': }
        ::apache::mod { 'usertrack': }

        if versioncmp($apache_version, '2.4') >= 0 {
          ::apache::mod { 'authn_core': }
        }
        else {
          ::apache::mod { 'authn_alias': }
          ::apache::mod { 'authn_default': }
        }
      }
      'freebsd': {
        include ::apache::mod::actions
        include ::apache::mod::cache
        include ::apache::mod::disk_cache
        include ::apache::mod::headers
        include ::apache::mod::info
        include ::apache::mod::mime_magic
        include ::apache::mod::reqtimeout
        include ::apache::mod::rewrite
        include ::apache::mod::userdir
        include ::apache::mod::version
        include ::apache::mod::vhost_alias
        include ::apache::mod::speling
        include ::apache::mod::filter

        ::apache::mod { 'asis': }
        ::apache::mod { 'auth_digest': }
        ::apache::mod { 'auth_form': }
        ::apache::mod { 'authn_anon': }
        ::apache::mod { 'authn_core': }
        ::apache::mod { 'authn_dbm': }
        ::apache::mod { 'authn_socache': }
        ::apache::mod { 'authz_dbd': }
        ::apache::mod { 'authz_dbm': }
        ::apache::mod { 'authz_owner': }
        ::apache::mod { 'dumpio': }
        ::apache::mod { 'expires': }
        ::apache::mod { 'file_cache': }
        ::apache::mod { 'imagemap':}
        ::apache::mod { 'include': }
        ::apache::mod { 'logio': }
        ::apache::mod { 'request': }
        ::apache::mod { 'session': }
        ::apache::mod { 'unique_id': }
      }
      default: {}
    }
    case $::apache::mpm_module {
      'prefork': {
        include ::apache::mod::cgi
      }
      'worker': {
        include ::apache::mod::cgid
      }
      default: {
        # do nothing
      }
    }
    include ::apache::mod::alias
    include ::apache::mod::authn_file
    include ::apache::mod::autoindex
    include ::apache::mod::dav
    include ::apache::mod::dav_fs
    include ::apache::mod::deflate
    include ::apache::mod::dir
    include ::apache::mod::mime
    include ::apache::mod::negotiation
    include ::apache::mod::setenvif
    ::apache::mod { 'auth_basic': }

    if versioncmp($apache_version, '2.4') >= 0 {
      # filter is needed by mod_deflate
      include ::apache::mod::filter

      # authz_core is needed for 'Require' directive
      ::apache::mod { 'authz_core':
        id => 'authz_core_module',
      }

      # lots of stuff seems to break without access_compat
      ::apache::mod { 'access_compat': }
    } else {
      include ::apache::mod::authz_default
    }

    include ::apache::mod::authz_user

    ::apache::mod { 'authz_groupfile': }
    ::apache::mod { 'env': }
  } elsif $mods {
    ::apache::default_mods::load { $mods: }

    if versioncmp($apache_version, '2.4') >= 0 {
      # authz_core is needed for 'Require' directive
      ::apache::mod { 'authz_core':
        id => 'authz_core_module',
      }

      # filter is needed by mod_deflate
      include ::apache::mod::filter
    }
  } else {
    if versioncmp($apache_version, '2.4') >= 0 {
      # authz_core is needed for 'Require' directive
      ::apache::mod { 'authz_core':
        id => 'authz_core_module',
      }

      # filter is needed by mod_deflate
      include ::apache::mod::filter
    }
  }
}
