##2015-03-03 - Supported Release 3.3.0
###Summary
This release includes major README updates, the addition of backup providers, and a fix for managing the log-bin directory.

####Features
- Add package_manage parameters to `mysql::server` and `mysql::client` (MODULES-1143)
- README improvements
- Add `mysqldump`, `mysqlbackup`, and `xtrabackup` backup providers.

####Bugfixes
- log-error overrides were not being properly used (MODULES-1804)
- check for full path for log-bin to stop puppet from managing file '.'

##2015-02-09 - Supported Release 3.2.0
###Summary
This release includes several new features and bugfixes, including support for various plugins, making the output from mysql_password more consistent when input is empty and improved username validation.

####Features
- Add type and provider to manage plugins
- Add support for authentication plugins
- Add support for mysql_install_db on freebsd
- Add `create_root_user` and `create_root_my_cnf` parameters to `mysql::server`

####Bugfixes
- Remove dependency on stdlib >= 4.1.0 (MODULES-1759)
- Make grant autorequire user
- Remove invalid parameter 'provider' from mysql_user instance (MODULES-1731)
- Return empty string for empty input in mysql_password
- Fix `mysql::account_security` when fqdn==localhost
- Update username validation (MODULES-1520)
- Future parser fix in params.pp
- Fix package name for debian 8
- Don't start the service until the server package is installed and the config file is in place
- Test fixes
- Lint fixes

##2014-12-16 - Supported Release 3.1.0
###Summary

This release includes several new features, including SLES12 support, and a number of bug fixes.

####Notes

`mysql::server::mysqltuner` has been refactored to fetch the mysqltuner script from github by default. If you are running on a non-network-connected system, you will need to download that file and have it available to your node at a path specified by the `source` parameter to the `mysqltuner` class.

####Features
- Add support for install_options for all package resources (MODULES-1484)
- Add log-bin directory creation
- Allow mysql::db to import multiple files (MODULES-1338)
- SLES12 support
- Improved identifier quoting detections
- Reworked `mysql::server::mysqltuner` so that we are no longer packaging the script as it is licensed under the GPL.

####Bugfixes
- Fix regression in username validation
- Proper containment for mysql::client in mysql::db
- Support quoted usernames of length 15 and 16 chars

##2014-11-11 - Supported Release 3.0.0
###Summary

Added several new features including MariaDB support and future parser

####Backwards-incompatible Changes
* Remove the deprecated `database`, `database_user`, and `database_grant` resources. The correct resources to use are `mysql`, `mysql_user`, and `mysql_grant` respectively.

####Features
* Add MariaDB Support
* The mysqltuner perl script has been updated to 1.3.0 based on work at http://github.com/major/MySQLTuner-perl
* Add future parse support, fixed issues with undef to empty string
* Pass the backup credentials to 'SHOW DATABASES'
* Ability to specify the Includedir for `mysql::server`
* `mysql::db` now has an import\_timeout feature that defaults to 300
* The `mysql` class has been removed
* `mysql::server` now takes an `override_options` hash that will affect the installation
* Ability to install both dev and client dev 

####BugFix
* `mysql::server::backup` now passes `ensure` param to the nested `mysql_grant`
* `mysql::server::service` now properly requires the presence of the `log_error` file
* `mysql::config` now occurs before `mysql::server::install_db` correctly

##2014-07-15 - Supported Release 2.3.1
###Summary

This release merely updates metadata.json so the module can be uninstalled and
upgraded via the puppet module command.

##2014-05-14 - Supported Release 2.3.0

This release primarily adds support for RHEL7 and Ubuntu 14.04 but it
also adds a couple of new parameters to allow for further customization,
as well as ensuring backups can backup stored procedures properly.

####Features
Added `execpath` to allow a custom executable path for non-standard mysql installations.
Added `dbname` to mysql::db and use ensure_resource to create the resource.
Added support for RHEL7 and Fedora Rawhide.
Added support for Ubuntu 14.04.
Create a warning for if you disable SSL.
Ensure the error logfile is owned by MySQL.
Disable ssl on FreeBSD.
Add PROCESS privilege for backups.

####Bugfixes

####Known Bugs
* No known bugs

##2014-03-04 - Supported Release 2.2.3
###Summary

This is a supported release.  This release removes a testing symlink that can
cause trouble on systems where /var is on a seperate filesystem from the
modulepath.

####Features
####Bugfixes
####Known Bugs
* No known bugs

##2014-03-04 - Supported Release 2.2.2
###Summary
This is a supported release. Mostly comprised of enhanced testing, plus a
bugfix for Suse.

####Bugfixes
- PHP bindings on Suse
- Test fixes

####Known Bugs
* No known bugs

##2014-02-19 - Version 2.2.1

###Summary

Minor release that repairs mysql_database{} so that it sees the correct
collation settings (it was only checking the global mysql ones, not the
actual database and constantly setting it over and over since January 22nd).

Also fixes a bunch of tests on various platforms.


##2014-02-13 - Version 2.2.0

###Summary

####Features
- Add `backupdirmode`, `backupdirowner`, `backupdirgroup` to
  mysql::server::backup to allow customizing the mysqlbackupdir.
- Support multiple options of the same name, allowing you to
  do 'replicate-do-db' => ['base1', 'base2', 'base3'] in order to get three
  lines of replicate-do-db = base1, replicate-do-db = base2 etc.

####Bugfixes
- Fix `restart` so it actually stops mysql restarting if set to false.
- DRY out the defaults_file functionality in the providers.
- mysql_grant fixed to work with root@localhost/@.
- mysql_grant fixed for WITH MAX_QUERIES_PER_HOUR
- mysql_grant fixed so revoking all privileges accounts for GRANT OPTION
- mysql_grant fixed to remove duplicate privileges.
- mysql_grant fixed to handle PROCEDURES when removing privileges.
- mysql_database won't try to create existing databases, breaking replication.
- bind_address renamed bind-address in 'mysqld' options.
- key_buffer renamed to key_buffer_size.
- log_error renamed to log-error.
- pid_file renamed to pid-file.
- Ensure mysql::server:root_password runs before mysql::server::backup
- Fix options_override -> override_options in the README.
- Extensively rewrite the README to be accurate and awesome.
- Move to requiring stdlib 3.2.0, shipped in PE3.0
- Add many new tests.


##2013-11-13 - Version 2.1.0

###Summary

The most important changes in 2.1.0 are improvements to the my.cnf creation,
as well as providers.  Setting options to = true strips them to be just the
key name itself, which is required for some options.

The provider updates fix a number of bugs, from lowercase privileges to
deprecation warnings.

Last, the new hiera integration functionality should make it easier to
externalize all your grants, users, and, databases.  Another great set of
community submissions helped to make this release.

####Features
- Some options can not take a argument. Gets rid of the '= true' when an
option is set to true.
- Easier hiera integration:  Add hash parameters to mysql::server to allow
specifying grants, users, and databases.

####Bugfixes
- Fix an issue with lowercase privileges in mysql_grant{} causing them to be reapplied needlessly.
- Changed defaults-file to defaults-extra-file in providers.
- Ensure /root/.my.cnf is 0600 and root owned.
- database_user deprecation warning was incorrect.
- Add anchor pattern for client.pp
- Documentation improvements.
- Various test fixes.


##2013-10-21 - Version 2.0.1

###Summary

This is a bugfix release to handle an issue where unsorted mysql_grant{}
privileges could cause Puppet to incorrectly reapply the permissions on
each run.

####Bugfixes
- Mysql_grant now sorts privileges in the type and provider for comparison.
- Comment and test tweak for PE3.1.


##2013-10-14 - Version 2.0.0

###Summary

(Previously detailed in the changelog for 2.0.0-rc1)

This module has been completely refactored and works significantly different.
The changes are broad and touch almost every piece of the module.

See the README.md for full details of all changes and syntax.
Please remain on 1.0.0 if you don't have time to fully test this in dev.

* mysql::server, mysql::client, and mysql::bindings are the primary interface
classes.
* mysql::server takes an `override_options` parameter to set my.cnf options,
with the hash format: { 'section' => { 'thing' => 'value' }}
* mysql attempts backwards compatibility by forwarding all parameters to
mysql::server.


##2013-10-09 - Version 2.0.0-rc5

###Summary

Hopefully the final rc!  Further fixes to mysql_grant (stripping out the
cleverness so we match a much wider range of input.)

####Bugfixes
- Make mysql_grant accept '.*'@'.*' in terms of input for user@host.


##2013-10-09 - Version 2.0.0-rc4

###Summary

Bugfixes to mysql_grant and mysql_user form the bulk of this rc, as well as
ensuring that values in the override_options hash that contain a value of ''
are created as just "key" in the conf rather than "key =" or "key = false".

####Bugfixes
- Improve mysql_grant to work with IPv6 addresses (both long and short).
- Ensure @host users work as well as user@host users.
- Updated my.cnf template to support items with no values.


##2013-10-07 - Version 2.0.0-rc3

###Summary
Fix mysql::server::monitor's use of mysql_user{}.

####Bugfixes
- Fix myql::server::monitor's use of mysql_user{} to grant the proper
permissions.  Add specs as well.  (Thanks to treydock!)


##2013-10-03 - Version 2.0.0-rc2

###Summary
Bugfixes

####Bugfixes
- Fix a duplicate parameter in mysql::server


##2013-10-03 - Version 2.0.0-rc1

###Summary

This module has been completely refactored and works significantly different.
The changes are broad and touch almost every piece of the module.

See the README.md for full details of all changes and syntax.
Please remain on 1.0.0 if you don't have time to fully test this in dev.

* mysql::server, mysql::client, and mysql::bindings are the primary interface
classes.
* mysql::server takes an `override_options` parameter to set my.cnf options,
with the hash format: { 'section' => { 'thing' => 'value' }}
* mysql attempts backwards compatibility by forwarding all parameters to
mysql::server.

---
##2013-09-23 - Version 1.0.0

###Summary

This release introduces a number of new type/providers, to eventually
replace the database_ ones.  The module has been converted to call the
new providers rather than the previous ones as they have a number of
fixes, additional options, and work with puppet resource.

This 1.0.0 release precedes a large refactoring that will be released
almost immediately after as 2.0.0.

####Features
- Added mysql_grant, mysql_database, and mysql_user.
- Add `mysql::bindings` class and refactor all other bindings to be contained underneath mysql::bindings:: namespace.
- Added support to back up specified databases only with 'mysqlbackup' parameter.
- Add option to mysql::backup to set the backup script to perform a mysqldump on each database to its own file

####Bugfixes
- Update my.cnf.pass.erb to allow custom socket support
- Add environment variable for .my.cnf in mysql::db.
- Add HOME environment variable for .my.cnf to mysqladmin command when
(re)setting root password

---
##2013-07-15 - Version 0.9.0
####Features
- Add `mysql::backup::backuprotate` parameter
- Add `mysql::backup::delete_before_dump` parameter
- Add `max_user_connections` attribute to `database_user` type

####Bugfixes
- Add client package dependency for `mysql::db`
- Remove duplicate `expire_logs_days` and `max_binlog_size` settings
- Make root's `.my.cnf` file path dynamic
- Update pidfile path for Suse variants
- Fixes for lint

##2013-07-05 - Version 0.8.1
####Bugfixes
 - Fix a typo in the Fedora 19 support.

##2013-07-01 - Version 0.8.0
####Features
 - mysql::perl class to install perl-DBD-mysql.
 - minor improvements to the providers to improve reliability
 - Install the MariaDB packages on Fedora 19 instead of MySQL.
 - Add new `mysql` class parameters:
   -  `max_connections`: The maximum number of allowed connections.
   -  `manage_config_file`: Opt out of puppetized control of my.cnf.
   -  `ft_min_word_len`: Fine tune the full text search.
   -  `ft_max_word_len`: Fine tune the full text search.
 - Add new `mysql` class performance tuning parameters:
   -  `key_buffer`
   -  `thread_stack`
   -  `thread_cache_size`
   -  `myisam-recover`
   -  `query_cache_limit`
   -  `query_cache_size`
   -  `max_connections`
   -  `tmp_table_size`
   -  `table_open_cache`
   -  `long_query_time`
 - Add new `mysql` class replication parameters:
   -  `server_id`
   -  `sql_log_bin`
   -  `log_bin`
   -  `max_binlog_size`
   -  `binlog_do_db`
   -  `expire_logs_days`
   -  `log_bin_trust_function_creators`
   -  `replicate_ignore_table`
   -  `replicate_wild_do_table`
   -  `replicate_wild_ignore_table`
   -  `expire_logs_days`
   -  `max_binlog_size`

####Bugfixes
 - No longer restart MySQL when /root/.my.cnf changes.
 - Ensure mysql::config runs before any mysql::db defines.

##2013-06-26 - Version 0.7.1
####Bugfixes
- Single-quote password for special characters
- Update travis testing for puppet 3.2.x and missing Bundler gems

##2013-06-25 - Version 0.7.0
This is a maintenance release for community bugfixes and exposing
configuration variables.

* Add new `mysql` class parameters:
  -  `basedir`: The base directory mysql uses
  -  `bind_address`: The IP mysql binds to
  -  `client_package_name`: The name of the mysql client package
  -  `config_file`: The location of the server config file
  -  `config_template`: The template to use to generate my.cnf
  -  `datadir`: The directory MySQL's datafiles are stored
  -  `default_engine`: The default engine to use for tables
  -  `etc_root_password`: Whether or not to add the mysql root password to
 /etc/my.cnf
  -  `java_package_name`: The name of the java package containing the java
 connector
  -  `log_error`: Where to log errors
  -  `manage_service`: Boolean dictating if mysql::server should manage the
 service
  -  `max_allowed_packet`: Maximum network packet size mysqld will accept
  -  `old_root_password`: Previous root user password
  -  `php_package_name`: The name of the phpmysql package to install
  -  `pidfile`: The location mysql will expect the pidfile to be
  -  `port`: The port mysql listens on
  -  `purge_conf_dir`: Value fed to recurse and purge parameters of the
 /etc/mysql/conf.d resource
  -  `python_package_name`: The name of the python mysql package to install
  -  `restart`: Whether to restart mysqld
  -  `root_group`: Use specified group for root-owned files
  -  `root_password`: The root MySQL password to use
  -  `ruby_package_name`: The name of the ruby mysql package to install
  -  `ruby_package_provider`: The installation suite to use when installing the
 ruby package
  -  `server_package_name`: The name of the server package to install
  -  `service_name`: The name of the service to start
  -  `service_provider`: The name of the service provider
  -  `socket`: The location of the MySQL server socket file
  -  `ssl_ca`: The location of the SSL CA Cert
  -  `ssl_cert`: The location of the SSL Certificate to use
  -  `ssl_key`: The SSL key to use
  -  `ssl`: Whether or not to enable ssl
  -  `tmpdir`: The directory MySQL's tmpfiles are stored
* Deprecate `mysql::package_name` parameter in favor of
`mysql::client_package_name`
* Fix local variable template deprecation
* Fix dependency ordering in `mysql::db`
* Fix ANSI quoting in queries
* Fix travis support (but still messy)
* Fix typos

##2013-01-11 - Version 0.6.1
* Fix providers when /root/.my.cnf is absent

##2013-01-09 - Version 0.6.0
* Add `mysql::server::config` define for specific config directives
* Add `mysql::php` class for php support
* Add `backupcompress` parameter to `mysql::backup`
* Add `restart` parameter to `mysql::config`
* Add `purge_conf_dir` parameter to `mysql::config`
* Add `manage_service` parameter to `mysql::server`
* Add syslog logging support via the `log_error` parameter
* Add initial SuSE support
* Fix remove non-localhost root user when fqdn != hostname
* Fix dependency in `mysql::server::monitor`
* Fix .my.cnf path for root user and root password
* Fix ipv6 support for users
* Fix / update various spec tests
* Fix typos
* Fix lint warnings

##2012-08-23 - Version 0.5.0
* Add puppetlabs/stdlib as requirement
* Add validation for mysql privs in provider
* Add `pidfile` parameter to mysql::config
* Add `ensure` parameter to mysql::db
* Add Amazon linux support
* Change `bind_address` parameter to be optional in my.cnf template
* Fix quoting root passwords

##2012-07-24 - Version 0.4.0
* Fix various bugs regarding database names
* FreeBSD support
* Allow specifying the storage engine
* Add a backup class
* Add a security class to purge default accounts

##2012-05-03 - Version 0.3.0
* 14218 Query the database for available privileges
* Add mysql::java class for java connector installation
* Use correct error log location on different distros
* Fix set_mysql_rootpw to properly depend on my.cnf

##2012-04-11 - Version 0.2.0

##2012-03-19 - William Van Hevelingen <blkperl@cat.pdx.edu>
* (#13203) Add ssl support (f7e0ea5)

##2012-03-18 - Nan Liu <nan@puppetlabs.com>
* Travis ci before script needs success exit code. (0ea463b)

##2012-03-18 - Nan Liu <nan@puppetlabs.com>
* Fix Puppet 2.6 compilation issues. (9ebbbc4)

##2012-03-16 - Nan Liu <nan@puppetlabs.com>
* Add travis.ci for testing multiple puppet versions. (33c72ef)

##2012-03-15 - William Van Hevelingen <blkperl@cat.pdx.edu>
* (#13163) Datadir should be configurable (f353fc6)

##2012-03-16 - Nan Liu <nan@puppetlabs.com>
* Document create_resources dependency. (558a59c)

##2012-03-16 - Nan Liu <nan@puppetlabs.com>
* Fix spec test issues related to error message. (eff79b5)

##2012-03-16 - Nan Liu <nan@puppetlabs.com>
* Fix mysql service on Ubuntu. (72da2c5)

##2012-03-16 - Dan Bode <dan@puppetlabs.com>
* Add more spec test coverage (55e399d)

##2012-03-16 - Nan Liu <nan@puppetlabs.com>
* (#11963) Fix spec test due to path changes. (1700349)

##2012-03-07 - François Charlier <fcharlier@ploup.net>
* Add a test to check path for 'mysqld-restart' (b14c7d1)

##2012-03-07 - François Charlier <fcharlier@ploup.net>
* Fix path for 'mysqld-restart' (1a9ae6b)

##2012-03-15 - Dan Bode <dan@puppetlabs.com>
* Add rspec-puppet tests for mysql::config (907331a)

##2012-03-15 - Dan Bode <dan@puppetlabs.com>
* Moved class dependency between sever and config to server (da62ad6)

##2012-03-14 - Dan Bode <dan@puppetlabs.com>
* Notify mysql restart from set_mysql_rootpw exec (0832a2c)

##2012-03-15 - Nan Liu <nan@puppetlabs.com>
* Add documentation related to osfamily fact. (8265d28)

##2012-03-14 - Dan Bode <dan@puppetlabs.com>
* Mention osfamily value in failure message (e472d3b)

##2012-03-14 - Dan Bode <dan@puppetlabs.com>
* Fix bug when querying for all database users (015490c)

##2012-02-09 - Nan Liu <nan@puppetlabs.com>
* Major refactor of mysql module. (b1f90fd)

##2012-01-11 - Justin Ellison <justin.ellison@buckle.com>
* Ruby and Python's MySQL libraries are named differently on different distros. (1e926b4)

##2012-01-11 - Justin Ellison <justin.ellison@buckle.com>
* Per @ghoneycutt, we should fail explicitly and explain why. (09af083)

##2012-01-11 - Justin Ellison <justin.ellison@buckle.com>
* Removing duplicate declaration (7513d03)

##2012-01-10 - Justin Ellison <justin.ellison@buckle.com>
* Use socket value from params class instead of hardcoding. (663e97c)

##2012-01-10 - Justin Ellison <justin.ellison@buckle.com>
* Instead of hardcoding the config file target, pull it from mysql::params (031a47d)

##2012-01-10 - Justin Ellison <justin.ellison@buckle.com>
* Moved $socket to within the case to toggle between distros.  Added a $config_file variable to allow per-distro config file destinations. (360eacd)

##2012-01-10 - Justin Ellison <justin.ellison@buckle.com>
* Pretty sure this is a bug, 99% of Linux distros out there won't ever hit the default. (3462e6b)

##2012-02-09 - William Van Hevelingen <blkperl@cat.pdx.edu>
* Changed the README to use markdown (3b7dfeb)

##2012-02-04 - Daniel Black <grooverdan@users.sourceforge.net>
* (#12412) mysqltuner.pl update (b809e6f)

##2011-11-17 - Matthias Pigulla <mp@webfactory.de>
* (#11363) Add two missing privileges to grant: event_priv, trigger_priv (d15c9d1)

##2011-12-20 - Jeff McCune <jeff@puppetlabs.com>
* (minor) Fixup typos in Modulefile metadata (a0ed6a1)

##2011-12-19 - Carl Caum <carl@carlcaum.com>
* Only notify Exec to import sql if sql is given (0783c74)

##2011-12-19 - Carl Caum <carl@carlcaum.com>
* (#11508) Only load sql_scripts on DB creation (e3b9fd9)

##2011-12-13 - Justin Ellison <justin.ellison@buckle.com>
* Require not needed due to implicit dependencies (3058feb)

##2011-12-13 - Justin Ellison <justin.ellison@buckle.com>
* Bug #11375: puppetlabs-mysql fails on CentOS/RHEL (a557b8d)

##2011-06-03 - Dan Bode <dan@puppetlabs.com> - 0.0.1
* initial commit
