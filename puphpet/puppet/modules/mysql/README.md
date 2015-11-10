#MySQL

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Backwards compatibility information](#backwards-compatibility)
3. [Setup - The basics of getting started with mysql](#setup)
    * [Beginning with mysql](#beginning-with-mysql)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Customizing Server Options](#customizing-server-options)
    * [Creating a Database](#creating-a-database)
    * [Custom Configuration](#custom-configuration)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

The mysql module installs, configures, and manages the MySQL service.

##Module Description

The mysql module manages both the installation and configuration of MySQL, as well as extending Puppet to allow management of MySQL resources, such as databases, users, and grants.

##Setup

###What MySQL affects

* MySQL package
* MySQL configuration files
* MySQL service

###Beginning with MySQL

If you want a server installed with the default options you can run
`include '::mysql::server'`. 

If you need to customize options, such as the root
password or `/etc/my.cnf` settings, then you must also pass in an override hash:

~~~
class { '::mysql::server':
  root_password           => 'strongpassword',
  remove_default_accounts => true,
  override_options        => $override_options
}
~~~

See [**Customizing Server Options**](#customizing-server-options) below for examples of the hash structure for $override_options`.

##Usage

All interaction for the server is done via `mysql::server`. To install the client, use `mysql::client`. To install bindings, use `mysql::bindings`.

###Customizing Server Options

The hash structure for overrides in `mysql::server` can be structured like a hash in the my.cnf file, so:

~~~
$override_options = {
  'section' => {
    'item' => 'thing',
  }
}
~~~

For items that you would traditionally represent as

~~~
[section]
thing = X
~~~

you can make an entry like `thing => true`, `thing => value`, or `thing => "` in the hash. Alternatively, you can pass an array, as `thing => ['value', 'value2']`, or list each `thing => value` separately on separate lines. 

MySQL doesn't care if 'thing' is alone or set to a value; it happily accepts both. To keep an option out of the my.cnf file --- e.g., when using `override_options` to revert to a default value --- you can pass `thing => undef`.

If an option needs multiple instances, you can pass an array. For example,

~~~
$override_options = {
  'mysqld' => {
    'replicate-do-db' => ['base1', 'base2'],
  }
}
~~~

produces

~~~
[mysql]
replicate-do-db = base1
replicate-do-db = base2
~~~

### Creating a database

To use `mysql::db` to create a database with a user and assign some privileges:

~~~
mysql::db { 'mydb':
  user     => 'myuser',
  password => 'mypass',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE'],
}
~~~

Or to use a different resource name with exported resources:

~~~
 @@mysql::db { "mydb_${fqdn}":
  user     => 'myuser',
  password => 'mypass',
  dbname   => 'mydb',
  host     => ${fqdn},
  grant    => ['SELECT', 'UPDATE'],
  tag      => $domain,
}
~~~

Then you can collect it on the remote DB server:

~~~
Mysql::Db <<| tag == $domain |>>
~~~

If you set the sql param to a file when creating a database, the file gets imported into the new database.

For large sql files, you should raise the $import_timeout parameter, set by default to 300 seconds.

~~~
mysql::db { 'mydb':
  user     => 'myuser',
  password => 'mypass',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE'],
  sql      => '/path/to/sqlfile',
  import_timeout => 900,
}
~~~

###Custom Configuration

To add custom MySQL configuration, drop additional files into
`includedir`. Dropping files into `includedir` allows you to override settings or add additional ones, which is helpful if you choose not to use `override_options` in `mysql::server`. The `includedir` location is by default set to /etc/mysql/conf.d.

##Reference

###Classes

####Public classes
* `mysql::server`: Installs and configures MySQL.
* `mysql::server::account_security`: Deletes default MySQL accounts.
* `mysql::server::monitor`: Sets up a monitoring user.
* `mysql::server::mysqltuner`: Installs MySQL tuner script.
* `mysql::server::backup`: Sets up MySQL backups via cron.
* `mysql::bindings`: Installs various MySQL language bindings.
* `mysql::client`: Installs MySQL client (for non-servers).

####Private classes
* `mysql::server::install`: Installs packages.
* `mysql::server::config`: Configures MYSQL.
* `mysql::server::service`: Manages service.
* `mysql::server::account_security`: Deletes default MySQL accounts.
* `mysql::server::root_password`: Sets MySQL root password.
* `mysql::server::providers`: Creates users, grants, and databases.
* `mysql::bindings::client_dev`: Installs MySQL client development package.
* `mysql::bindings::daemon_dev`: Installs MySQL daemon development package.
* `mysql::bindings::java`: Installs Java bindings.
* `mysql::bindings::perl`: Installs Perl bindings.
* `mysql::bindings::php`: Installs PHP bindings.
* `mysql::bindings::python`: Installs Python bindings.
* `mysql::bindings::ruby`: Installs Ruby bindings.
* `mysql::client::install`:  Installs MySQL client.
* `mysql::backup::mysqldump`: Implements mysqldump backups.
* `mysql::backup::mysqlbackup`: Implements backups with Oracle MySQL Enterprise Backup.
* `mysql::backup::xtrabackup`: Implements backups with XtraBackup from Percona.

###Parameters

####mysql::server

#####`create_root_user`

Specify whether root user should be created. Valid values are 'true', 'false'. Defaults to 'true'.

This is useful for a cluster setup with Galera. The root user has to
be created only once. `create_root_user` can be set to 'true' on one node while
it is set to 'false' on the remaining nodes.

#####`create_root_my_cnf`

If set to 'true', creates `/root/.my.cnf`. Valid values are 'true', 'false'. Defaults to 'true'.

`create_root_my_cnf` allows creation of `/root/.my.cnf` independently of `create_root_user`. This can be used for a cluster setup with Galera where you want `/root/.my.cnf` to exist on all nodes.

#####`root_password`

The MySQL root password. Puppet attempts to set the root password and update `/root/.my.cnf` with it.

This is required if `create_root_user` or `create_root_my_cnf` are 'true'. If `root_password` is 'UNSET', then `create_root_user` and `create_root_my_cnf` are assumed to be false --- that is, the MySQL root user and `/root/.my.cnf` are not created.

#####`old_root_password`

The previous root password. Required if you want to change the root password via Puppet.

#####`override_options`

The hash of override options to pass into MySQL. Structured like a hash in the my.cnf file:

~~~
$override_options = {
  'section' => {
    'item'             => 'thing',
  }
}
~~~

See [**Customizing Server Options**](#customizing-server-options) above for usage details.

#####`config_file`

The location, as a path, of the MySQL configuration file.

#####`manage_config_file`

Whether the MySQL configuration file should be managed. Valid values are 'true', 'false'. Defaults to 'true'.

#####`includedir`
The location, as a path, of !includedir for custom configuration overrides.

#####`install_options`
Pass [install_options](https://docs.puppetlabs.com/references/latest/type.html#package-attribute-install_options) array to managed package resources. You must pass the appropriate options for the specified package manager.

#####`purge_conf_dir`

Whether the `includedir` directory should be purged. Valid values are 'true', 'false'. Defaults to 'false'.

#####`restart`

Whether the service should be restarted when things change. Valid values are 'true', 'false'. Defaults to 'false'.

#####`root_group`

The name of the group used for root. Can be a group name or a group ID. See more about the [`group` file attribute](https://docs.puppetlabs.com/references/latest/type.html#file-attribute-group).

#####`package_ensure`

Whether the package exists or should be a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Defaults to 'present'.

#####`package_manage`

Whether to manage the mysql server package. Defaults to true.

#####`package_name`

The name of the MySQL server package to install.

#####`remove_default_accounts`

Specify whether to automatically include `mysql::server::account_security`. Valid values are 'true', 'false'. Defaults to 'false'.

#####`service_enabled`

Specify whether the service should be enabled. Valid values are 'true', 'false'. Defaults to 'true'.

#####`service_manage`

Specify whether the service should be managed. Valid values are 'true', 'false'. Defaults to 'true'.

#####`service_name`

The name of the MySQL server service. Defaults are OS dependent, defined in params.pp.

#####`service_provider`

The provider to use to manage the service. For Ubuntu, defaults to 'upstart'; otherwise, default is undefined.

#####`users`

Optional hash of users to create, which are passed to [mysql_user](#mysql_user). 

~~~
users => {
  'someuser@localhost' => {
    ensure                   => 'present',
    max_connections_per_hour => '0',
    max_queries_per_hour     => '0',
    max_updates_per_hour     => '0',
    max_user_connections     => '0',
    password_hash            => '*F3A2A51A9B0F2BE2468926B4132313728C250DBF',
  },
}
~~~

#####`grants`

Optional hash of grants, which are passed to [mysql_grant](#mysql_grant). 

~~~
grants => {
  'someuser@localhost/somedb.*' => {
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['SELECT', 'INSERT', 'UPDATE', 'DELETE'],
    table      => 'somedb.*',
    user       => 'someuser@localhost',
  },
}
~~~

#####`databases`

Optional hash of databases to create, which are passed to [mysql_database](#mysql_database).

~~~
databases   => {
  'somedb'  => {
    ensure  => 'present',
    charset => 'utf8',
  },
}
~~~

####mysql::server::backup

#####`backupuser`

MySQL user to create for backups.

#####`backuppassword`

MySQL user password for backups.

#####`backupdir`

Directory in which to store backups.

#####`backupdirmode`

Permissions applied to the backup directory. This parameter is passed directly
to the `file` resource.

#####`backupdirowner`

Owner for the backup directory. This parameter is passed directly to the `file`
resource.

#####`backupdirgroup`

Group owner for the backup directory. This parameter is passed directly to the
`file` resource.

#####`backupcompress`

Whether backups should be compressed. Valid values are 'true', 'false'. Defaults to 'true'.

#####`backuprotate`

How many days to keep backups. Valid value is an integer. Defaults to '30'.

#####`delete_before_dump`

Whether to delete old .sql files before backing up. Setting to 'true' deletes old files before backing up, while setting to 'false' deletes them after backup. Valid values are 'true', 'false'. Defaults to 'false'.

#####`backupdatabases`

Specify an array of databases to back up.

#####`file_per_database`

Whether a separate file be used per database. Valid values are 'true', 'false'. Defaults to 'false'.

#####`ensure`

Allows you to remove the backup scripts. Valid values are 'present', 'absent'. Defaults to 'present'.

#####`execpath`

Allows you to set a custom PATH should your MySQL installation be non-standard places. Defaults to `/usr/bin:/usr/sbin:/bin:/sbin`.

#####`time`

An array of two elements to set the backup time. Allows ['23', '5'] (i.e., 23:05) or ['3', '45'] (i.e., 03:45) for HH:MM times.

#####`postscript`

A script that is executed at when the backup is finished. This could be used to (r)sync the backup to a central store. This script can be either a single line that is directly executed or a number of lines supplied as an array. It could also be one or more externally managed (executable) files.

#####`provider`

Sets the server backup implementation. Valid values are:

* `mysqldump`: Implements backups with mysqldump. Backup type: Logical. This is the default value.
* `mysqlbackup`: Implements backups with MySQL Enterprise Backup from Oracle. Backup type: Physical. To use this type of backup, you'll need the `meb` package, which is available in RPM and TAR formats from Oracle. For Ubuntu, you can use [meb-deb](https://github.com/dveeden/meb-deb) to create a package from an official tarball.
* `xtrabackup`: Implements backups with XtraBackup from Percona. Backup type: Physical.

####mysql::server::monitor

#####`mysql_monitor_username`

The username to create for MySQL monitoring.

#####`mysql_monitor_password`

The password to create for MySQL monitoring.

#####`mysql_monitor_hostname`

The hostname from which the monitoring user requests are allowed access. 

####mysql::server::mysqltuner

**Note**: If you're using this class on a non-network-connected system, you must download the mysqltuner.pl script and have it hosted somewhere accessible via `http(s)://`, `puppet://`, `ftp://`, or a fully qualified file path.

##### `ensure`

Ensures that the resource exists. Valid values are `present`, `absent`. Defaults to `present`.

##### `version`

The version to install from the major/MySQLTuner-perl github repository. Must be a valid tag. Defaults to 'v1.3.0'.

##### `source`

Parameter to optionally specify the source. If not specified, defaults to `https://github.com/major/MySQLTuner-perl/raw/${version}/mysqltuner.pl`

####mysql::bindings

##### `client_dev`

Specify whether `::mysql::bindings::client_dev` should be included. Valid values are true', 'false'. Defaults to 'false'.

##### `daemon_dev`

Specify whether `::mysql::bindings::daemon_dev` should be included. Valid values are 'true', 'false'. Defaults to 'false'.

##### `java_enable`

Specify whether `::mysql::bindings::java` should be included. Valid values are 'true', 'false'. Defaults to 'false'.

##### `perl_enable`

Specify whether `mysql::bindings::perl` should be included. Valid values are 'true', 'false'. Defaults to 'false'.

##### `php_enable`

Specify whether `mysql::bindings::php` should be included. Valid values are 'true', 'false'. Defaults to 'false'.

##### `python_enable`

Specify whether `mysql::bindings::python` should be included. Valid values are 'true', 'false'. Defaults to 'false'.

##### `ruby_enable`

Specify whether `mysql::bindings::ruby` should be included. Valid values are 'true', 'false'. Defaults to 'false'.

##### `install_options`

Pass `install_options` array to managed package resources. You must pass the [appropriate options](https://docs.puppetlabs.com/references/latest/type.html#package-attribute-install_options) for the package manager(s).

##### `client_dev_package_ensure`

Whether the package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Only applies if `client_dev => true`.
 
##### `client_dev_package_name`

The name of the client_dev package to install. Only applies if `client_dev => true`.
 
##### `client_dev_package_provider`

The provider to use to install the client_dev package. Only applies if `client_dev => true`.

##### `daemon_dev_package_ensure`

Whether the package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Only applies if `daemon_dev => true`.

##### `daemon_dev_package_name`

The name of the daemon_dev package to install. Only applies if `daemon_dev => true`.

##### `daemon_dev_package_provider`

The provider to use to install the daemon_dev package. Only applies if `daemon_dev => true`.

#####`java_package_ensure`

Whether the package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Only applies if `java_enable => true`.

#####`java_package_name`

The name of the Java package to install. Only applies if `java_enable => true`.

#####`java_package_provider`

The provider to use to install the Java package. Only applies if `java_enable => true`.

#####`perl_package_ensure`

Whether the package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Only applies if `perl_enable => true`.

#####`perl_package_name`

The name of the Perl package to install. Only applies if `perl_enable => true`.

#####`perl_package_provider`

The provider to use to install the Perl package. Only applies if `perl_enable => true`.

##### `php_package_ensure`

Whether the package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Only applies if `php_enable => true`.
 
##### `php_package_name`

The name of the PHP package to install. Only applies if `php_enable => true`.

#####`python_package_ensure`

Whether the package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Only applies if `python_enable => true`.

#####`python_package_name`

The name of the Python package to install. Only applies if `python_enable => true`.

#####`python_package_provider`

The provider to use to install the PHP package. Only applies if `python_enable => true`.

#####`ruby_package_ensure`

Whether the package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Only applies if `ruby_enable => true`.

#####`ruby_package_name`

The name of the Ruby package to install. Only applies if `ruby_enable => true`.

#####`ruby_package_provider`

What provider should be used to install the package.

####mysql::client

#####`bindings_enable`

Whether to automatically install all bindings. Valid values are 'true', 'false'. Default to 'false'.

#####`install_options`
Array of install options for managed package resources. You must pass the appropriate options for the package manager.

#####`package_ensure`

Whether the MySQL package should be present, absent, or a specific version. Valid values are 'present', 'absent', or 'x.y.z'.

#####`package_manage`

Whether to manage the mysql client package. Defaults to true.

#####`package_name`

The name of the MySQL client package to install.

###Defined Types

####mysql::db

~~~
mysql_database { 'information_schema':
  ensure  => 'present',
  charset => 'utf8',
  collate => 'utf8_swedish_ci',
}
mysql_database { 'mysql':
  ensure  => 'present',
  charset => 'latin1',
  collate => 'latin1_swedish_ci',
}
~~~

##### `user`

The user for the database you're creating.
 
##### `password`

The password for $user for the database you're creating.

##### `dbname`

The name of the database to create. Defaults to $name.
 
##### `charset`

The character set for the database. Defaults to 'utf8'.

##### `collate`

The collation for the database. Defaults to 'utf8_general_ci'.
 
##### `host`

The host to use as part of user@host for grants. Defaults to 'localhost'.

##### `grant`

The privileges to be granted for user@host on the database. Defaults to 'ALL'.

##### `sql`

The path to the sqlfile you want to execute. This can be single file specified as string, or it can be an array of strings. Defaults to undef.

##### `enforce_sql`

Specify whether executing the sqlfiles should happen on every run. If set to 'false', sqlfiles only run once. Valid values are 'true', 'false'. Defaults to 'false'.
 
##### `ensure`

Specify whether to create the database. Valid values are 'present', 'absent'. Defaults to 'present'. 

##### `import_timeout`

Timeout, in seconds, for loading the sqlfiles. Defaults to '300'.


###Types

####mysql_database

`mysql_database` creates and manages databases within MySQL.

##### `ensure`

Whether the resource is present. Valid values are 'present', 'absent'. Defaults to 'present'.

##### `name`

The name of the MySQL database to manage.

##### `charset`

The CHARACTER SET setting for the database. Defaults to ':utf8'.

##### `collate`

The COLLATE setting for the database. Defaults to ':utf8_general_ci'. 

####mysql_user

Creates and manages user grants within MySQL.

~~~
mysql_user { 'root@127.0.0.1':
  ensure                   => 'present',
  max_connections_per_hour => '0',
  max_queries_per_hour     => '0',
  max_updates_per_hour     => '0',
  max_user_connections     => '0',
}
~~~

You can also specify an authentication plugin.

~~~
mysql_user{ 'myuser'@'localhost':
  ensure                   => 'present',
  plugin                   => 'unix_socket',
}
~~~

##### `name`

The name of the user, as 'username@hostname' or username@hostname.

##### `password_hash`

The user's password hash of the user. Use mysql_password() for creating such a hash.

##### `max_user_connections`

Maximum concurrent connections for the user. Must be an integer value. A value of '0' specifies no (or global) limit.

##### `max_connections_per_hour`

Maximum connections per hour for the user. Must be an integer value. A value of '0' specifies no (or global) limit.

##### `max_queries_per_hour`

Maximum queries per hour for the user. Must be an integer value. A value of '0' specifies no (or global) limit.

##### `max_updates_per_hour`

Maximum updates per hour for the user. Must be an integer value. A value of '0' specifies no (or global) limit.


####mysql_grant

`mysql_grant` creates grant permissions to access databases within
MySQL. To use it you must create the title of the resource as shown below,
following the pattern of `username@hostname/database.table`:

~~~
mysql_grant { 'root@localhost/*.*':
  ensure     => 'present',
  options    => ['GRANT'],
  privileges => ['ALL'],
  table      => '*.*',
  user       => 'root@localhost',
}
~~~

It is possible to specify privileges down to the column level:

~~~
mysql_grant { 'root@localhost/mysql.user':
  ensure     => 'present',
  privileges => ['SELECT (Host, User)'],
  table      => 'mysql.user',
  user       => 'root@localhost',
}
~~~

##### `ensure`

Whether the resource is present. Valid values are 'present', 'absent'. Defaults to 'present'.

##### `name`

Name to describe the grant. Must in a 'user/table' format. 

##### `privileges`

Privileges to grant the user.

##### `table`

The table to which privileges are applied.

##### `user`

User to whom privileges are granted.

##### `options`

MySQL options to grant. Optional.

####mysql_plugin

`mysql_plugin` can be used to load plugins into the MySQL Server.

~~~
mysql_plugin { 'auth_socket':
  ensure     => 'present',
  soname     => 'auth_socket.so',
}
~~~

##### `ensure`

Whether the resource is present. Valid values are 'present', 'absent'. Defaults to 'present'.

##### `name`

The name of the MySQL plugin to manage.

##### `soname`

The library file name.

##Limitations

This module has been tested on:

* RedHat Enterprise Linux 5, 6, 7
* Debian 6, 7
* CentOS 5, 6, 7
* Ubuntu 10.04, 12.04, 14.04
* Scientific Linux 5, 6
* SLES 11

Testing on other platforms has been minimal and cannot be guaranteed.

#Development

Puppet Labs modules on the Puppet Forge are open projects, and community
contributions are essential for keeping them great. We can’t access the
huge number of platforms and myriad of hardware, software, and deployment
configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our
modules work in your environment. There are a few guidelines that we need
contributors to follow so that we can have a chance of keeping on top of things.

Check out our the complete [module contribution guide](https://docs.puppetlabs.com/forge/contributing.html).

### Authors

This module is based on work by David Schmitt. The following contributors have contributed to this module (beyond Puppet Labs):

* Larry Ludwig
* Christian G. Warden
* Daniel Black
* Justin Ellison
* Lowe Schmidt
* Matthias Pigulla
* William Van Hevelingen
* Michael Arnold
* Chris Weyl
* Daniël van Eeden

