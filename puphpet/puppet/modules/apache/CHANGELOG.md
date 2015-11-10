##2015-03-17 - Supported Release 1.4.0
###Summary

This release fixes the issue where the docroot was still managed even if the default vhosts were disabled and has many other features and bugfixes including improved support for 'deny' and 'require' as arrays in the 'directories' parameter under `apache::vhost`

####Features
- New parameters to `apache`
  - `default_charset`
  - `default_type`
- New parameters to `apache::vhost`
  - `proxy_error_override`
  - `passenger_app_env` (MODULES-1776)
  - `proxy_dest_match`
  - `proxy_dest_reverse_match`
  - `proxy_pass_match`
  - `no_proxy_uris_match`
- New parameters to `apache::mod::passenger`
  - `passenger_app_env`
  - `passenger_min_instances`
- New parameter to `apache::mod::alias`
  - `icons_options`
- New classes added under `apache::mod::*`
  - `authn_file`
  - `authz_default`
  - `authz_user`
- Added support for 'deny' as an array in 'directories' under `apache::vhost`
- Added support for RewriteMap
- Improved support for FreeBSD. (Note: If using apache < 2.4.12, see the discussion [here](https://github.com/puppetlabs/puppetlabs-apache/pull/1030))
- Added check for deprecated options in directories and fail when they are unsupported
- Added gentoo compatibility
- Added proper array support for `require` in the `directories` parameter in `apache::vhost`
- Added support for `setenv` inside proxy locations

###Bugfixes
- Fix issue in `apache::vhost` that was preventing the scriptalias fragment from being included (MODULES-1784)
- Install required `mod_ldap` package for EL7 (MODULES-1779)
- Change default value of `maxrequestworkers` in `apache::mod::event` to be a multiple of the default `ThreadsPerChild` of 25.
- Use the correct `mod_prefork` package name for trusty and jessie
- Don't manage docroot when default vhosts are disabled
- Ensure resources notify `Class['Apache::Service']` instead of `Service['httpd']` (MODULES-1829)
- Change the loadfile name for `mod_passenger` so `mod_proxy` will load by default before `mod_passenger`
- Remove old Debian work-around that removed `passenger_extra.conf`

##2015-02-17 - Supported Release 1.3.0
###Summary

This release has many new features and bugfixes, including the ability to optionally not trigger service restarts on config changes.

####Features
- New parameters - `apache`
  - `service_manage`
  - `use_optional_includes`
- New parameters - `apache::service`
  - `service_manage`
- New parameters - `apache::vhost`
  - `access_logs`
  - `php_flags`
  - `php_values`
  - `modsec_disable_vhost`
  - `modsec_disable_ids`
  - `modsec_disable_ips`
  - `modsec_body_limit`
- Improved FreeBSD support
- Add ability to omit priority prefix if `$priority` is set to false
- Add `apache::security::rule_link` define
- Improvements to `apache::mod::*`
  - Add `apache::mod::auth_cas` class
  - Add `threadlimit`, `listenbacklog`, `maxrequestworkers`, `maxconnectionsperchild` parameters to `apache::mod::event`
  - Add `apache::mod::filter` class
  - Add `root_group` to `apache::mod::php`
  - Add `apache::mod::proxy_connect` class
  - Add `apache::mod::security` class
  - Add `ssl_pass_phrase_dialog` and `ssl_random_seed_bytes parameters to `apache::mod::ssl` (MODULES-1719)
  - Add `status_path` parameter to `apache::mod::status`
  - Add `apache_version` parameter to `apache::mod::version`
  - Add `package_name` and `mod_path` parameters to `apache::mod::wsgi` (MODULES-1458)
- Improved SCL support
  - Add support for specifying the docroot
- Updated `_directories.erb` to add support for SetEnv
- Support multiple access log directives (MODULES-1382)
- Add passenger support for Debian Jessie
- Add support for not having puppet restart the apache service (MODULES-1559)

####Bugfixes
- For apache 2.4 `mod_itk` requires `mod_prefork` (MODULES-825)
- Allow SSLCACertificatePath to be unset in `apache::vhost` (MODULES-1457)
- Load fcgid after unixd on RHEL7
- Allow disabling default vhost for Apache 2.4
- Test fixes
- `mod_version` is now built-in (MODULES-1446)
- Sort LogFormats for idempotency
- `allow_encoded_slashes` was omitted from `apache::vhost`
- Fix documentation bug (MODULES-1403, MODULES-1510)
- Sort `wsgi_script_aliases` for idempotency (MODULES-1384)
- lint fixes
- Fix automatic version detection for Debian Jessie
- Fix error docs and icons path for RHEL7-based systems (MODULES-1554)
- Sort php_* hashes for idempotency (MODULES-1680)
- Ensure `mod::setenvif` is included if needed (MODULES-1696)
- Fix indentation in `vhost/_directories.erb` template (MODULES-1688)
- Create symlinks on all distros if `vhost_enable_dir` is specified

##2014-09-30 - Supported Release 1.2.0
###Summary

This release features many improvements and bugfixes, including several new defines, a reworking of apache::vhost for more extensibility, and many new parameters for more customization. This release also includes improved support for strict variables and the future parser.

####Features
- Convert apache::vhost to use concat for easier extensions
- Test improvements
- Synchronize files with modulesync
- Strict variable and future parser support
- Added apache::custom_config defined type to allow validation of configs before they are created
- Added bool2httpd function to convert true/false to apache 'On' and 'Off'. Intended for internal use in the module.
- Improved SCL support
  - allow overriding of the mod_ssl package name
- Add support for reverse_urls/ProxyPassReverse in apache::vhost
- Add satisfy directive in apache::vhost::directories
- Add apache::fastcgi::server defined type
- New parameters - apache
  - allow_encoded_slashes
  - apache_name
  - conf_dir
  - default_ssl_crl_check
  - docroot
  - logroot_mode
  - purge_vhost_dir
- New parameters - apache::vhost
  - add_default_charset
  - allow_encoded_slashes
  - logroot_ensure
  - logroot_mode
  - manage_docroot
  - passenger_app_root
  - passenger_min_instances
  - passenger_pre_start
  - passenger_ruby
  - passenger_start_timeout
  - proxy_preserve_host
  - redirectmatch_dest
  - ssl_crl_check
  - wsgi_chunked_request
  - wsgi_pass_authorization
- Add support for ScriptAlias and ScriptAliasMatch in the apache::vhost::aliases parameter
- Add support for rewrites in the apache::vhost::directories parameter
- If the service_ensure parameter in apache::service is set to anything other than true, false, running, or stopped, ensure will not be passed to the service resource, allowing for the service to not be managed by puppet
- Turn of SSLv3 by default
- Improvements to apache::mod*
  - Add restrict_access parameter to apache::mod::info
  - Add force_language_priority and language_priority parameters to apache::mod::negotiation
  - Add threadlimit parameter to apache::mod::worker
  - Add content, template, and source parameters to apache::mod::php
  - Add mod_authz_svn support via the authz_svn_enabled parameter in apache::mod::dav_svn
  - Add loadfile_name parameter to apache::mod
  - Add apache::mod::deflate class
  - Add options parameter to apache::mod::fcgid
  - Add timeouts parameter to apache::mod::reqtimeout
  - Add apache::mod::shib
  - Add apache_version parameter to apache::mod::ldap
  - Add magic_file parameter to apache::mod::mime_magic
  - Add apache_version parameter to apache::mod::pagespeed
  - Add passenger_default_ruby parameter to apache::mod::passenger
  - Add content, template, and source parameters to apache::mod::php
  - Add apache_version parameter to apache::mod::proxy
  - Add loadfiles parameter to apache::mod::proxy_html
  - Add ssl_protocol and package_name parameters to apache::mod::ssl
  - Add apache_version parameter to apache::mod::status
  - Add apache_version parameter to apache::mod::userdir
  - Add apache::mod::version class

####Bugfixes
- Set osfamily defaults for wsgi_socket_prefix
- Support multiple balancermembers with the same url
- Validate apache::vhost::custom_fragment
- Add support for itk with mod_php
- Allow apache::vhost::ssl_certs_dir to not be set
- Improved passenger support for Debian
- Improved 2.4 support without mod_access_compat
- Support for more than one 'Allow from'-directive in _directories.erb
- Don't load systemd on Amazon linux based on CentOS6 with apache 2.4
- Fix missing newline in ModPagespeed filter and memcached servers directive
- Use interpolated strings instead of numbers where required by future parser
- Make auth_require take precedence over default with apache 2.4
- Lint fixes
- Set default for php_admin_flags and php_admin_values to be empty hash instead of empty array
- Correct typo in mod::pagespeed
- spec_helper fixes
- Install mod packages before dealing with the configuration
- Use absolute scope to check class definition in apache::mod::php
- Fix dependency loop in apache::vhost
- Properly scope variables in the inline template in apache::balancer
- Documentation clarification, typos, and formatting
- Set apache::mod::ssl::ssl_mutex to default for debian on apache >= 2.4
- Strict variables fixes
- Add authn_core mode to Ubuntu trusty defaults
- Keep default loadfile for authz_svn on Debian
- Remove '.conf' from the site-include regexp for better Ubuntu/Debian support
- Load unixd before fcgid for EL7
- Fix RedirectMatch rules
- Fix misleading error message in apache::version

####Known Bugs
* By default, the version of Apache that ships with Ubuntu 10.04 does not work with `wsgi_import_script`.
* SLES is unsupported.

##2014-07-15 - Supported Release 1.1.1
###Summary

This release merely updates metadata.json so the module can be uninstalled and
upgraded via the puppet module command.

## 2014-04-14 Supported Release 1.1.0

###Summary

This release primarily focuses on extending the httpd 2.4 support, tested
through adding RHEL7 and Ubuntu 14.04 support.  It also includes Passenger 
4 support, as well as several new modules and important bugfixes.

####Features

- Add support for RHEL7 and Ubuntu 14.04
- More complete apache24 support
- Passenger 4 support
- Add support for max_keepalive_requests and log_formats parameters
- Add mod_pagespeed support
- Add mod_speling support
- Added several parameters for mod_passenger
- Added ssl_cipher parameter to apache::mod::ssl
- Improved examples in documentation
- Added docroot_mode, action, and suexec_user_group parameters to apache::vhost
- Add support for custom extensions for mod_php
- Improve proxy_html support for Debian

####Bugfixes

- Remove NameVirtualHost directive for apache >= 2.4
- Order proxy_set option so it doesn't change between runs
- Fix inverted SSL compression
- Fix missing ensure on concat::fragment resources
- Fix bad dependencies in apache::mod and apache::mod::mime

####Known Bugs
* By default, the version of Apache that ships with Ubuntu 10.04 does not work with `wsgi_import_script`.
* SLES is unsupported.

## 2014-03-04 Supported Release 1.0.1
###Summary

This is a supported release.  This release removes a testing symlink that can
cause trouble on systems where /var is on a seperate filesystem from the
modulepath.

####Features
####Bugfixes
####Known Bugs
* By default, the version of Apache that ships with Ubuntu 10.04 does not work with `wsgi_import_script`.
* SLES is unsupported.
 
## 2014-03-04 Supported Release 1.0.0
###Summary

This is a supported release. This release introduces Apache 2.4 support for
Debian and RHEL based osfamilies.

####Features

- Add apache24 support
- Add rewrite_base functionality to rewrites
- Updated README documentation
- Add WSGIApplicationGroup and WSGIImportScript directives

####Bugfixes

- Replace mutating hashes with merge() for Puppet 3.5
- Fix WSGI import_script and mod_ssl issues on Lucid

####Known Bugs
* By default, the version of Apache that ships with Ubuntu 10.04 does not work with `wsgi_import_script`.
* SLES is unsupported.

---

## 2014-01-31 Release 0.11.0
### Summary:

This release adds preliminary support for Windows compatibility and multiple rewrite support.

#### Backwards-incompatible Changes:

- The rewrite_rule parameter is deprecated in favor of the new rewrite parameter
  and will be removed in a future release.

#### Features:

- add Match directive
- quote paths for windows compatibility
- add auth_group_file option to README.md
- allow AuthGroupFile directive for vhosts
- Support Header directives in vhost context
- Don't purge mods-available dir when separate enable dir is used
- Fix the servername used in log file name
- Added support for mod_include
- Remove index parameters.
- Support environment variable control for CustomLog
- added redirectmatch support
- Setting up the ability to do multiple rewrites and conditions.
- Convert spec tests to beaker.
- Support php_admin_(flag|value)s

#### Bugfixes:

- directories are either a Hash or an Array of Hashes
- Configure Passenger in separate .conf file on RH so PassengerRoot isn't lost
- (docs) Update list of `apache::mod::[name]` classes
- (docs) Fix apache::namevirtualhost example call style
- Fix $ports_file reference in apache::listen.
- Fix $ports_file reference in Namevirtualhost.


## 2013-12-05 Release 0.10.0
### Summary:

This release adds FreeBSD osfamily support and various other improvements to some mods.

#### Features:

- Add suPHP_UserGroup directive to directory context
- Add support for ScriptAliasMatch directives
- Set SSLOptions StdEnvVars in server context
- No implicit <Directory> entry for ScriptAlias path
- Add support for overriding ErrorDocument
- Add support for AliasMatch directives
- Disable default "allow from all" in vhost-directories
- Add WSGIPythonPath as an optional parameter to mod_wsgi. 
- Add mod_rpaf support
- Add directives: IndexOptions, IndexOrderDefault
- Add ability to include additional external configurations in vhost
- need to use the provider variable not the provider key value from the directory hash for matches
- Support for FreeBSD and few other features
- Add new params to apache::mod::mime class
- Allow apache::mod to specify module id and path
- added $server_root parameter
- Add Allow and ExtendedStatus support to mod_status
- Expand vhost/_directories.pp directive support
- Add initial support for nss module (no directives in vhost template yet)
- added peruser and event mpms
- added $service_name parameter
- add parameter for TraceEnable
- Make LogLevel configurable for server and vhost
- Add documentation about $ip
- Add ability to pass ip (instead of wildcard) in default vhost files

#### Bugfixes:

- Don't listen on port or set NameVirtualHost for non-existent vhost
- only apply Directory defaults when provider is a directory
- Working mod_authnz_ldap support on Debian/Ubuntu

## 2013-09-06 Release 0.9.0
### Summary:
This release adds more parameters to the base apache class and apache defined
resource to make the module more flexible. It also adds or enhances SuPHP,
WSGI, and Passenger mod support, and support for the ITK mpm module.

#### Backwards-incompatible Changes:
- Remove many default mods that are not normally needed.
- Remove `rewrite_base` `apache::vhost` parameter; did not work anyway.
- Specify dependencies on stdlib >=2.4.0 (this was already the case, but
making explicit)
- Deprecate `a2mod` in favor of the `apache::mod::*` classes and `apache::mod`
defined resource.

#### Features:
- `apache` class
  - Add `httpd_dir` parameter to change the location of the configuration
  files.
  - Add `logroot` parameter to change the logroot
  - Add `ports_file` parameter to changes the `ports.conf` file location
  - Add `keepalive` parameter to enable persistent connections
  - Add `keepalive_timeout` parameter to change the timeout
  - Update `default_mods` to be able to take an array of mods to enable.
- `apache::vhost`
  - Add `wsgi_daemon_process`, `wsgi_daemon_process_options`,
  `wsgi_process_group`, and `wsgi_script_aliases` parameters for per-vhost
  WSGI configuration.
  - Add `access_log_syslog` parameter to enable syslogging.
  - Add `error_log_syslog` parameter to enable syslogging of errors.
  - Add `directories` hash parameter. Please see README for documentation.
  - Add `sslproxyengine` parameter to enable SSLProxyEngine
  - Add `suphp_addhandler`, `suphp_engine`, and `suphp_configpath` for
  configuring SuPHP.
  - Add `custom_fragment` parameter to allow for arbitrary apache
  configuration injection. (Feature pull requests are prefered over using
  this, but it is available in a pinch.)
- Add `apache::mod::suphp` class for configuring SuPHP.
- Add `apache::mod::itk` class for configuring ITK mpm module.
- Update `apache::mod::wsgi` class for global WSGI configuration with
`wsgi_socket_prefix` and `wsgi_python_home` parameters.
- Add README.passenger.md to document the `apache::mod::passenger` usage.
Added `passenger_high_performance`, `passenger_pool_idle_time`,
`passenger_max_requests`, `passenger_stat_throttle_rate`, `rack_autodetect`,
and `rails_autodetect` parameters.
- Separate the httpd service resource into a new `apache::service` class for
dependency chaining of `Class['apache'] -> <resource> ~>
Class['apache::service']`
- Added `apache::mod::proxy_balancer` class for `apache::balancer`

#### Bugfixes:
- Change dependency to puppetlabs-concat
- Fix ruby 1.9 bug for `a2mod`
- Change servername to be `$::hostname` if there is no `$::fqdn`
- Make `/etc/ssl/certs` the default ssl certs directory for RedHat non-5.
- Make `php` the default php package for RedHat non-5.
- Made `aliases` able to take a single alias hash instead of requiring an
array.

## 2013-07-26 Release 0.8.1
#### Bugfixes:
- Update `apache::mpm_module` detection for worker/prefork
- Update `apache::mod::cgi` and `apache::mod::cgid` detection for
worker/prefork

## 2013-07-16 Release 0.8.0
#### Features:
- Add `servername` parameter to `apache` class
- Add `proxy_set` parameter to `apache::balancer` define

#### Bugfixes:
- Fix ordering for multiple `apache::balancer` clusters
- Fix symlinking for sites-available on Debian-based OSs
- Fix dependency ordering for recursive confdir management
- Fix `apache::mod::*` to notify the service on config change
- Documentation updates

## 2013-07-09 Release 0.7.0
#### Changes:
- Essentially rewrite the module -- too many to list
- `apache::vhost` has many abilities -- see README.md for details
- `apache::mod::*` classes provide httpd mod-loading capabilities
- `apache` base class is much more configurable

#### Bugfixes:
- Many. And many more to come

## 2013-03-2 Release 0.6.0
- update travis tests (add more supported versions)
- add access log_parameter
- make purging of vhost dir configurable

## 2012-08-24 Release 0.4.0
#### Changes:
- `include apache` is now required when using `apache::mod::*`

#### Bugfixes:
- Fix syntax for validate_re
- Fix formatting in vhost template
- Fix spec tests such that they pass

##2012-05-08 Puppet Labs <info@puppetlabs.com> - 0.0.4
* e62e362 Fix broken tests for ssl, vhost, vhost::*
* 42c6363 Changes to match style guide and pass puppet-lint without error
* 42bc8ba changed name => path for file resources in order to name namevar by it's name
* 72e13de One end too much
* 0739641 style guide fixes: 'true' <> true, $operatingsystem needs to be $::operatingsystem, etc.
* 273f94d fix tests
* a35ede5 (#13860) Make a2enmod/a2dismo commands optional
* 98d774e (#13860) Autorequire Package['httpd']
* 05fcec5 (#13073) Add missing puppet spec tests
* 541afda (#6899) Remove virtual a2mod definition
* 976cb69 (#13072) Move mod python and wsgi package names to params
* 323915a (#13060) Add .gitignore to repo
* fdf40af (#13060) Remove pkg directory from source tree
* fd90015 Add LICENSE file and update the ModuleFile
* d3d0d23 Re-enable local php class
* d7516c7 Make management of firewalls configurable for vhosts
* 60f83ba Explicitly lookup scope of apache_name in templates.
* f4d287f (#12581) Add explicit ordering for vdir directory
* 88a2ac6 (#11706) puppetlabs-apache depends on puppetlabs-firewall
* a776a8b (#11071) Fix to work with latest firewall module
* 2b79e8b (#11070) Add support for Scientific Linux
* 405b3e9 Fix for a2mod
* 57b9048 Commit apache::vhost::redirect Manifest
* 8862d01 Commit apache::vhost::proxy Manifest
* d5c1fd0 Commit apache::mod::wsgi Manifest
* a825ac7 Commit apache::mod::python Manifest
* b77062f Commit Templates
* 9a51b4a Vhost File Declarations
* 6cf7312 Defaults for Parameters
* 6a5b11a Ensure installed
* f672e46 a2mod fix
* 8a56ee9 add pthon support to apache
