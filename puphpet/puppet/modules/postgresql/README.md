postgresql
==========

Table of Contents
-----------------

1. [Overview - What is the PostgreSQL module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with PostgreSQL module](#setup)
    * [PE 3.2 supported module](#pe-32-supported-module)
    * [Configuring the server](#configuring-the-server) 
4. [Usage - How to use the module for various tasks](#usage)
5. [Reference - The classes, defines,functions and facts available in this module](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Transfer Notice - Notice of authorship change](#transfer-notice)
9. [Contributors - List of module contributors](#contributors)

Overview
--------

The PostgreSQL module allows you to easily manage postgres databases with Puppet.

Module Description
-------------------

PostgreSQL is a high-performance, free, open-source relational database server. The postgresql module allows you to manage PostgreSQL packages and services on several operating systems, while also supporting basic management of PostgreSQL databases and users. The module offers support for basic management of common security settings.

Setup
-----

**What puppetlabs-PostgreSQL affects:**

* package/service/configuration files for PostgreSQL
* listened-to ports
* IP and mask (optional)

**Introductory Questions**

The postgresql module offers many security configuration settings. Before getting started, you will want to consider:

* Do you want/need to allow remote connections?
    * If yes, what about TCP connections?
* How restrictive do you want the database superuser's permissions to be?

Your answers to these questions will determine which of the module's parameters you'll want to specify values for.

###PE 3.2 supported module

PE 3.2 introduces Puppet Labs supported modules. The version of the postgresql module that ships within PE 3.2 is supported via normal [Puppet Enterprise support](http://puppetlabs.com/services/customer-support) channels. If you would like to access the [supported module](http://forge.puppetlabs.com/supported) version, you will need to uninstall the shipped module and install the supported version from the Puppet Forge. You can do this by first running

    # puppet module uninstall puppetlabs-postgresql
and then running

    # puppet module install puppetlabs/postgresql

###Configuring the server

The main configuration you'll need to do will be around the `postgresql::server` class. The default parameters are reasonable, but fairly restrictive regarding permissions for who can connect and from where. To manage a PostgreSQL server with sane defaults:

    class { 'postgresql::server': }

For a more customized configuration:

    class { 'postgresql::server':
      ip_mask_deny_postgres_user => '0.0.0.0/32',
      ip_mask_allow_all_users    => '0.0.0.0/0',
      listen_addresses           => '*',
      ipv4acls                   => ['hostssl all johndoe 192.168.0.0/24 cert'],
      postgres_password          => 'TPSrep0rt!',
    }

Once you've completed your configuration of `postgresql::server`, you can test out your settings from the command line:

    $ psql -h localhost -U postgres
    $ psql -h my.postgres.server -U

If you get an error message from these commands, it means that your permissions are set in a way that restricts access from where you're trying to connect. That might be a good thing or a bad thing, depending on your goals.

For more details about server configuration parameters consult the [PostgreSQL Runtime Configuration docs](http://www.postgresql.org/docs/current/static/runtime-config.html).

Usage
-----

###Creating a database

There are many ways to set up a postgres database using the `postgresql::server::db` class. For instance, to set up a database for PuppetDB:

    class { 'postgresql::server': }

    postgresql::server::db { 'mydatabasename':
      user     => 'mydatabaseuser',
      password => postgresql_password('mydatabaseuser', 'mypassword'),
    }

###Managing users, roles and permissions

To manage users, roles and permissions:

    class { 'postgresql::server': }

    postgresql::server::role { 'marmot':
      password_hash => postgresql_password('marmot', 'mypasswd'),
    }

    postgresql::server::database_grant { 'test1':
      privilege => 'ALL',
      db        => 'test1',
      role      => 'marmot',
    }

    postgresql::server::table_grant { 'my_table of test2':
      privilege => 'ALL',
      table     => 'my_table',
      db        => 'test2',
      role      => 'marmot',
    }

In this example, you would grant ALL privileges on the test1 database and on the `my_table` table of the test2 database to the user or group specified by dan.

At this point, you would just need to plunk these database name/username/password values into your PuppetDB config files, and you are good to go.

Reference
---------

The postgresql module comes with many options for configuring the server. While you are unlikely to use all of the below settings, they allow you a decent amount of control over your security settings.

Classes:

* [postgresql::client](#class-postgresqlclient)
* [postgresql::globals](#class-postgresqlglobals)
* [postgresql::lib::devel](#class-postgresqllibdevel)
* [postgresql::lib::java](#class-postgresqllibjava)
* [postgresql::lib::perl](#class-postgresqllibperl)
* [postgresql::lib::python](#class-postgresqllibpython)
* [postgresql::server](#class-postgresqlserver)
* [postgresql::server::plperl](#class-postgresqlserverplperl)
* [postgresql::server::contrib](#class-postgresqlservercontrib)
* [postgresql::server::postgis](#class-postgresqlserverpostgis)

Resources:

* [postgresql::server::config_entry](#resource-postgresqlserverconfig_entry)
* [postgresql::server::db](#resource-postgresqlserverdb)
* [postgresql::server::database](#resource-postgresqlserverdatabase)
* [postgresql::server::database_grant](#resource-postgresqlserverdatabase_grant)
* [postgresql::server::extension](#resource-postgresqlserverextension)
* [postgresql::server::pg_hba_rule](#resource-postgresqlserverpg_hba_rule)
* [postgresql::server::pg_ident_rule](#resource-postgresqlserverpg_ident_rule)
* [postgresql::server::role](#resource-postgresqlserverrole)
* [postgresql::server::schema](#resource-postgresqlserverschema)
* [postgresql::server::table_grant](#resource-postgresqlservertable_grant)
* [postgresql::server::tablespace](#resource-postgresqlservertablespace)
* [postgresql::validate_db_connection](#resource-postgresqlvalidate_db_connection)

Functions:

* [postgresql\_password](#function-postgresql_password)
* [postgresql\_acls\_to\_resources\_hash](#function-postgresql_acls_to_resources_hashacl_array-id-order_offset)


###Class: postgresql::globals
*Note:* most server specific defaults should be overriden in the `postgresql::server` class. This class should only be used if you are using a non-standard OS or if you are changing elements such as `version` or `manage_package_repo` that can only be changed here.

This class allows you to configure the main settings for this module in a global way, to be used by the other classes and defined resources. On its own it does nothing.

For example, if you wanted to overwrite the default `locale` and `encoding` for all classes you could use the following combination:

    class { 'postgresql::globals':
      encoding => 'UTF-8',
      locale   => 'en_US.UTF-8',
    }->
    class { 'postgresql::server':
    }

That would make the `encoding` and `locale` the default for all classes and defined resources in this module.

If you want to use the upstream PostgreSQL packaging, and be specific about the version you wish to download, you could use something like this:

    class { 'postgresql::globals':
      manage_package_repo => true,
      version             => '9.2',
    }->
    class { 'postgresql::server': }

####`client_package_name`
This setting can be used to override the default postgresql client package name. If not specified, the module will use whatever package name is the default for your OS distro.

####`server_package_name`
This setting can be used to override the default postgresql server package name. If not specified, the module will use whatever package name is the default for your OS distro.

####`contrib_package_name`
This setting can be used to override the default postgresql contrib package name. If not specified, the module will use whatever package name is the default for your OS distro.

####`devel_package_name`
This setting can be used to override the default postgresql devel package name. If not specified, the module will use whatever package name is the default for your OS distro.

####`java_package_name`
This setting can be used to override the default postgresql java package name. If not specified, the module will use whatever package name is the default for your OS distro.

####`perl_package_name`
This setting can be used to override the default postgresql Perl package name. If not specified, the module will use whatever package name is the default for your OS distro.

####`plperl_package_name`
This setting can be used to override the default postgresql PL/perl package name. If not specified, the module will use whatever package name is the default for your OS distro.

####`python_package_name`
This setting can be used to override the default postgresql Python package name. If not specified, the module will use whatever package name is the default for your OS distro.

####`service_ensure`
This setting can be used to override the default postgresql service ensure status. If not specified, the module will use `ensure` instead.

####`service_name`
This setting can be used to override the default postgresql service name. If not specified, the module will use whatever service name is the default for your OS distro.

####`service_provider`
This setting can be used to override the default postgresql service provider. If not specified, the module will use whatever service provider is the default for your OS distro.

####`service_status`
This setting can be used to override the default status check command for your PostgreSQL service. If not specified, the module will use whatever service status is the default for your OS distro.

####`default_database`
This setting is used to specify the name of the default database to connect with. On most systems this will be "postgres".

####`initdb_path`
Path to the `initdb` command.

####`createdb_path`
Path to the `createdb` command.

####`psql_path`
Path to the `psql` command.

####`pg_hba_conf_path`
Path to your `pg\_hba.conf` file.

####`pg_ident_conf_path`
Path to your `pg\_ident.conf` file.

####`postgresql_conf_path`
Path to your `postgresql.conf` file.

####`pg_hba_conf_defaults`
If false, disables the defaults supplied with the module for `pg\_hba.conf`. This is useful if you disagree with the defaults and wish to override them yourself. Be sure that your changes of course align with the rest of the module, as some access is required to perform basic `psql` operations for example.

####`datadir`
This setting can be used to override the default postgresql data directory for the target platform. If not specified, the module will use whatever directory is the default for your OS distro. Please note that changing the datadir after installation will cause the server to come to a full stop before being able to make the change. For RedHat systems, the data directory must be labeled appropriately for SELinux. On Ubuntu, you need to explicitly set needs\_initdb to true in order to allow Puppet to initialize the database in the new datadir (needs\_initdb defaults to true on other systems).

Warning: If datadir is changed from the default, puppet will not manage purging of the original data directory, which will cause it to fail if the data directory is changed back to the original.

####`confdir`
This setting can be used to override the default postgresql configuration directory for the target platform. If not specified, the module will use whatever directory is the default for your OS distro.

####`bindir`
This setting can be used to override the default postgresql binaries directory for the target platform. If not specified, the module will use whatever directory is the default for your OS distro.

####`xlogdir`
This setting can be used to override the default postgresql xlog directory. If not specified the module will use initdb's default path.

####`user`
This setting can be used to override the default postgresql super user and owner of postgresql related files in the file system. If not specified, the module will use the user name 'postgres'.

####`group`
This setting can be used to override the default postgresql user group to be used for related files in the file system. If not specified, the module will use the group name 'postgres'.

####`version`
The version of PostgreSQL to install/manage. This is a simple way of providing a specific version such as '9.2' or '8.4' for example.

Defaults to your operating system default.

####`postgis_version`
The version of PostGIS to install if you install PostGIS. Defaults to the lowest available with the version of PostgreSQL to be installed.

####`needs_initdb`
This setting can be used to explicitly call the initdb operation after server package is installed and before the postgresql service is started. If not specified, the module will decide whether to call initdb or not depending on your OS distro.

####`encoding`
This will set the default encoding encoding for all databases created with this module. On certain operating systems this will be used during the `template1` initialization as well so it becomes a default outside of the module as well. Defaults to the operating system default.

####`locale`
This will set the default database locale for all databases created with this module. On certain operating systems this will be used during the `template1` initialization as well so it becomes a default outside of the module as well. Defaults to `undef` which is effectively `C`.

#####Debian

On Debian you'll need to ensure that the 'locales-all' package is installed for full functionality of Postgres.

####`manage_package_repo`
If `true` this will setup the official PostgreSQL repositories on your host. Defaults to `false`.

###Class: postgresql::server
The following list are options that you can set in the `config_hash` parameter of `postgresql::server`.

####`postgres_password`
This value defaults to `undef`, meaning the super user account in the postgres database is a user called `postgres` and this account does not have a password. If you provide this setting, the module will set the password for the `postgres` user to your specified value.

####`package_name`
The name of the package to use for installing the server software. Defaults to the default for your OS distro.

####`package_ensure`
Value to pass through to the `package` resource when creating the server instance. Defaults to `undef`.

####`plperl_package_name`
This sets the default package name for the PL/Perl extension. Defaults to utilising the operating system default.

####`service_manage`
This setting selects whether Puppet should manage the service. Defaults to `true`.

####`service_name`
This setting can be used to override the default postgresql service name. If not specified, the module will use whatever service name is the default for your OS distro.

####`service_provider`
This setting can be used to override the default postgresql service provider. If not specified, the module will use whatever service name is the default for your OS distro.

####`service_reload`
This setting can be used to override the default reload command for your PostgreSQL service. If not specified, the module will the default reload command for your OS distro.

####`service_status`
This setting can be used to override the default status check command for your PostgreSQL service. If not specified, the module will use whatever service name is the default for your OS distro.

####`default_database`
This setting is used to specify the name of the default database to connect with. On most systems this will be "postgres".

####`listen_addresses`
This value defaults to `localhost`, meaning the postgres server will only accept connections from localhost. If you'd like to be able to connect to postgres from remote machines, you can override this setting. A value of `*` will tell postgres to accept connections from any remote machine. Alternately, you can specify a comma-separated list of hostnames or IP addresses. (For more info, have a look at the `postgresql.conf` file from your system's postgres package).

####`port`
This value defaults to `5432`, meaning the postgres server will listen on TCP port 5432. Note that the same port number is used for all IP addresses the server listens on. Also note that for RedHat systems and early Debian systems, changing the port will cause the server to come to a full stop before being able to make the change.

####`ip_mask_deny_postgres_user`
This value defaults to `0.0.0.0/0`. Sometimes it can be useful to block the superuser account from remote connections if you are allowing other database users to connect remotely. Set this to an IP and mask for which you want to deny connections by the postgres superuser account. So, e.g., the default value of `0.0.0.0/0` will match any remote IP and deny access, so the postgres user won't be able to connect remotely at all. Conversely, a value of `0.0.0.0/32` would not match any remote IP, and thus the deny rule will not be applied and the postgres user will be allowed to connect.

####`ip_mask_allow_all_users`
This value defaults to `127.0.0.1/32`. By default, Postgres does not allow any database user accounts to connect via TCP from remote machines. If you'd like to allow them to, you can override this setting. You might set it to `0.0.0.0/0` to allow database users to connect from any remote machine, or `192.168.0.0/16` to allow connections from any machine on your local 192.168 subnet.

####`ipv4acls`
List of strings for access control for connection method, users, databases, IPv4 addresses; see [postgresql documentation](http://www.postgresql.org/docs/current/static/auth-pg-hba-conf.html) about `pg_hba.conf` for information (please note that the link will take you to documentation for the most recent version of Postgres, however links for earlier versions can be found on that page).

####`ipv6acls`
List of strings for access control for connection method, users, databases, IPv6 addresses; see [postgresql documentation](http://www.postgresql.org/docs/current/static/auth-pg-hba-conf.html) about `pg_hba.conf` for information (please note that the link will take you to documentation for the most recent version of Postgres, however links for earlier versions can be found on that page).

####`initdb_path`
Path to the `initdb` command.

####`createdb_path`
Path to the `createdb` command.

####`psql_path`
Path to the `psql` command.

####`pg_hba_conf_path`
Path to your `pg\_hba.conf` file.

####`pg_ident_conf_path`
Path to your `pg\_ident.conf` file.

####`postgresql_conf_path`
Path to your `postgresql.conf` file.

####`pg_hba_conf_defaults`
If false, disables the defaults supplied with the module for `pg\_hba.conf`. This is useful if you di
sagree with the defaults and wish to override them yourself. Be sure that your changes of course alig
n with the rest of the module, as some access is required to perform basic `psql` operations for exam
ple.

####`user`
This setting can be used to override the default postgresql super user and owner of postgresql related files in the file system. If not specified, the module will use the user name 'postgres'.

####`group`
This setting can be used to override the default postgresql user group to be used for related files in the file system. If not specified, the module will use the group name 'postgres'.

####`needs_initdb`
This setting can be used to explicitly call the initdb operation after server package is installed and before the postgresql service is started. If not specified, the module will decide whether to call initdb or not depending on your OS distro.

####`encoding`
This will set the default encoding encoding for all databases created with this module. On certain operating systems this will be used during the `template1` initialization as well so it becomes a default outside of the module as well. Defaults to the operating system default.

####`locale`
This will set the default database locale for all databases created with this module. On certain operating systems this will be used during the `template1` initialization as well so it becomes a default outside of the module as well. Defaults to `undef` which is effectively `C`.

#####Debian

On Debian you'll need to ensure that the 'locales-all' package is installed for full functionality of Postgres.

####`manage_pg_hba_conf`
This value defaults to `true`. Whether or not manage the pg_hba.conf. If set to `true`, puppet will overwrite this file. If set to `false`, puppet will not modify the file.

####`manage_pg_ident_conf`
This value defaults to `true`. Whether or not manage the pg_ident.conf. If set to `true`, puppet will overwrite this file. If set to `false`, puppet will not modify the file.

###Class: postgresql::client

This class installs postgresql client software. Alter the following parameters if you have a custom version you would like to install (Note: don't forget to make sure to add any necessary yum or apt repositories if specifying a custom version):

####`package_name`
The name of the postgresql client package.

####`package_ensure`
The ensure parameter passed on to postgresql client package resource.


###Class: postgresql::server::contrib
Installs the postgresql contrib package.

####`package_name`
The name of the postgresql contrib package.

####`package_ensure`
The ensure parameter passed on to postgresql contrib package resource.

###Class: postgresql::server::postgis
Installs the postgresql postgis packages.

###Class: postgresql::lib::devel
Installs the packages containing the development libraries for PostgreSQL and
symlinks pg_config into `/usr/bin` (if not in `/usr/bin` or `/usr/local/bin`).

####`package_ensure`
Override for the `ensure` parameter during package installation. Defaults to `present`.

####`package_name`
Overrides the default package name for the distribution you are installing to. Defaults to `postgresql-devel` or `postgresql<version>-devel` depending on your distro.

####`link_pg_config`
By default on all but Debian systems, if the bin directory used by the PostgreSQL package is not `/usr/bin` or `/usr/local/bin`,
this class will symlink `pg_config` from the package's bin dir into `/usr/bin`. Set `link_pg_config` to
false to disable this behavior.

###Class: postgresql::lib::java
This class installs postgresql bindings for Java (JDBC). Alter the following parameters if you have a custom version you would like to install (Note: don't forget to make sure to add any necessary yum or apt repositories if specifying a custom version):

####`package_name`
The name of the postgresql java package.

####`package_ensure`
The ensure parameter passed on to postgresql java package resource.


###Class: postgresql::lib::perl
This class installs the postgresql Perl libraries. For customer requirements you can customise the following parameters:

####`package_name`
The name of the postgresql perl package.

####`package_ensure`
The ensure parameter passed on to postgresql perl package resource.


###Class: postgresql::lib::python
This class installs the postgresql Python libraries. For customer requirements you can customise the following parameters:

####`package_name`
The name of the postgresql python package.

####`package_ensure`
The ensure parameter passed on to postgresql python package resource.


###Class: postgresql::server::plperl
This class installs the PL/Perl procedural language for postgresql.

####`package_name`
The name of the postgresql PL/Perl package.

####`package_ensure`
The ensure parameter passed on to postgresql PL/Perl package resource.


###Resource: postgresql::server::config\_entry
This resource can be used to modify your `postgresql.conf` configuration file.

Each resource maps to a line inside your `postgresql.conf` file, for example:

    postgresql::server::config_entry { 'check_function_bodies':
      value => 'off',
    }

####`namevar`
Name of the setting to change.

####`ensure`
Set to `absent` to remove an entry.

####`value`
Value for the setting.


###Resource: postgresql::server::db
This is a convenience resource that creates a database, user and assigns necessary permissions in one go.

For example, to create a database called `test1` with a corresponding user of the same name, you can use:

    postgresql::server::db { 'test1':
      user     => 'test1',
      password => 'test1',
    }

####`namevar`
The namevar for the resource designates the name of the database.

####`comment`
A comment to be stored about the database using the PostgreSQL COMMENT command.

####`dbname`
The name of the database to be created. Defaults to `namevar`.

####`owner`
Name of the database user who should be set as the owner of the database. Defaults to the $user variable set in `postgresql::server` or `postgresql::globals`.

####`user`
User to create and assign access to the database upon creation. Mandatory.

####`password`
Password for the created user. Mandatory.

####`encoding`
Override the character set during creation of the database. Defaults to the default defined during installation.

####`locale`
Override the locale during creation of the database. Defaults to the default defined during installation.

####`grant`
Grant permissions during creation. Defaults to `ALL`.

####`tablespace`
The name of the tablespace to allocate this database to. If not specifies, it defaults to the PostgreSQL default.

####`template`
The name of the template database from which to build this database. Defaults to `template0`.

####`istemplate`
Define database as a template. Defaults to `false`.


###Resource: postgresql::server::database
This defined type can be used to create a database with no users and no permissions, which is a rare use case.

####`namevar`
The name of the database to create.

####`dbname`
The name of the database, defaults to the namevar.

####`owner`
Name of the database user who should be set as the owner of the database. Defaults to the $user variable set in `postgresql::server` or `postgresql::globals`.

####`tablespace`
Tablespace for where to create this database. Defaults to the defaults defined during PostgreSQL installation.

####`template`
The name of the template database from which to build this database. Defaults to `template0`.

####`encoding`
Override the character set during creation of the database. Defaults to the default defined during installation.

####`locale`
Override the locale during creation of the database. Defaults to the default defined during installation.

####`istemplate`
Define database as a template. Defaults to `false`.


###Resource: postgresql::server::database\_grant
This defined type manages grant based access privileges for users, wrapping the `postgresql::server::database_grant` for database specific permissions. Consult the PostgreSQL documentation for `grant` for more information.

####`namevar`
Used to uniquely identify this resource, but functionality not used during grant.

####`privilege`
Can be one of `SELECT`, `TEMPORARY`, `TEMP`, `CONNECT`. `ALL` is used as a synonym for `CREATE`. If you need to add multiple privileges, a space delimited string can be used.

####`db`
Database to grant access to.

####`role`
Role or user whom you are granting access for.

####`psql_db`
Database to execute the grant against. This should not ordinarily be changed from the default, which is `postgres`.

####`psql_user`
OS user for running `psql`. Defaults to the default user for the module, usually `postgres`.


###Resource: postgresql::server::extension
Manages a postgresql extension.

####`database`
The database on which to activate the extension.

####`ensure`
Whether to activate (`present`) or deactivate (`absent`) the extension.

####`package_name`
If provided, this will install the given package prior to activating the extension.

####`package_ensure`
By default, the package specified with `package_name` will be installed when the extension is activated, and removed when the extension is deactivated. You can override this behavior by setting the `ensure` value for the package.

###Resource: postgresql::server::pg\_hba\_rule
This defined type allows you to create an access rule for `pg_hba.conf`. For more details see the [PostgreSQL documentation](http://www.postgresql.org/docs/8.2/static/auth-pg-hba-conf.html).

For example:

    postgresql::server::pg_hba_rule { 'allow application network to access app database':
      description => "Open up postgresql for access from 200.1.2.0/24",
      type => 'host',
      database => 'app',
      user => 'app',
      address => '200.1.2.0/24',
      auth_method => 'md5',
    }

This would create a ruleset in `pg_hba.conf` similar to:

    # Rule Name: allow application network to access app database
    # Description: Open up postgresql for access from 200.1.2.0/24
    # Order: 150
    host  app  app  200.1.2.0/24  md5

####`namevar`
A unique identifier or short description for this rule. The namevar doesn't provide any functional usage, but it is stored in the comments of the produced `pg_hba.conf` so the originating resource can be identified.

####`description`
A longer description for this rule if required. Defaults to `none`. This description is placed in the comments above the rule in `pg_hba.conf`.

####`type`
The type of rule, this is usually one of: `local`, `host`, `hostssl` or `hostnossl`.

####`database`
A comma separated list of databases that this rule matches.

####`user`
A comma separated list of database users that this rule matches.

####`address`
If the type is not 'local' you can provide a CIDR based address here for rule matching.

####`auth_method`
The `auth_method` is described further in the `pg_hba.conf` documentation, but it provides the method that is used for authentication for the connection that this rule matches.

####`auth_option`
For certain `auth_method` settings there are extra options that can be passed. Consult the PostgreSQL `pg_hba.conf` documentation for further details.

####`order`
An order for placing the rule in `pg_hba.conf`. Defaults to `150`.

####`target`
This provides the target for the rule, and is generally an internal only property. Use with caution.


###Resource: postgresql::server::pg\_ident\_rule
This defined type allows you to create user name maps for `pg_ident.conf`. For more details see the [PostgreSQL documentation](http://www.postgresql.org/docs/current/static/auth-username-maps.html).

For example:

    postgresql::server::pg_ident_rule{ 'Map the SSL certificate of the backup server as a replication user':
      map_name          => 'sslrepli',
      system_username   => 'repli1.example.com',
      database_username => 'replication',
    }

This would create a user name map in `pg_ident.conf` similar to:

    # Rule Name: Map the SSL certificate of the backup server as a replication user
    # Description: none
    # Order: 150
    sslrepli	repli1.example.com	replication

####`namevar`
A unique identifier or short description for this rule. The namevar doesn't provide any functional usage, but it is stored in the comments of the produced `pg_ident.conf` so the originating resource can be identified.

####`description`
A longer description for this rule if required. Defaults to `none`. This description is placed in the comments above the rule in `pg_ident.conf`.

####`map_name`
Name of the user map, that is used to refer to this mapping in `pg_hba.conf`.

####`system_username`
Operating system user name, the user name used to connect to the database.

####`database_username`
Database user name, the user name of the the database user. The `system_username` will be mapped to this user name.

####`order`
An order for placing the mapping in pg_ident.conf. Defaults to 150.

####`target`
This provides the target for the rule, and is generally an internal only property. Use with caution.


###Resource: postgresql::server::role
This resource creates a role or user in PostgreSQL.

####`namevar`
The role name to create.

####`password_hash`
The hash to use during password creation. If the password is not already pre-encrypted in a format that PostgreSQL supports, use the `postgresql_password` function to provide an MD5 hash here, for example:

    postgresql::server::role { "myusername":
      password_hash => postgresql_password('myusername', 'mypassword'),
    }

####`createdb`
Whether to grant the ability to create new databases with this role. Defaults to `false`.

####`createrole`
Whether to grant the ability to create new roles with this role. Defaults to `false`.

####`login`
Whether to grant login capability for the new role. Defaults to `true`.

####`inherit`
Whether to grant inherit capability for the new role. Defaults to `true`.

####`superuser`
Whether to grant super user capability for the new role. Defaults to `false`.

####`replication`
If `true` provides replication capabilities for this role. Defaults to `false`.

####`connection_limit`
Specifies how many concurrent connections the role can make. Defaults to `-1` meaning no limit.

####`username`
The username of the role to create, defaults to `namevar`.

###Resource: postgresql::server::schema
This defined type can be used to create a schema. For example:

    postgresql::server::schema { 'isolated':
      owner => 'jane',
      db    => 'janedb',
    }

It will create the schema `isolated` in the database `janedb` if neccessary,
assigning the user `jane` ownership permissions.

####`namevar`
The schema name to create.

###`db`
Name of the database in which to create this schema. This must be passed.

####`owner`
The default owner of the schema.

####`schema`
Name of the schma. Defaults to `namevar`.


###Resource: postgresql::server::table\_grant
This defined type manages grant based access privileges for users. Consult the PostgreSQL documentation for `grant` for more information.

####`namevar`
Used to uniquely identify this resource, but functionality not used during grant.

####`privilege`
Can be one of `SELECT`, `INSERT`, `UPDATE`, `REFERENCES`. `ALL` is used as a synonym for `CREATE`. If you need to add multiple privileges, a space delimited string can be used.

####`table`
Table to grant access on.

####`db`
Database of table.

####`role`
Role or user whom you are granting access for.

####`psql_db`
Database to execute the grant against. This should not ordinarily be changed from the default, which is `postgres`.

####`psql_user`
OS user for running `psql`. Defaults to the default user for the module, usually `postgres`.


###Resource: postgresql::server::tablespace
This defined type can be used to create a tablespace. For example:

    postgresql::server::tablespace { 'tablespace1':
      location => '/srv/space1',
    }

It will create the location if necessary, assigning it the same permissions as your
PostgreSQL server.

####`namevar`
The tablespace name to create.

####`location`
The path to locate this tablespace.

####`owner`
The default owner of the tablespace.

####`spcname`
Name of the tablespace. Defaults to `namevar`.


###Resource: postgresql::validate\_db\_connection
This resource can be utilised inside composite manifests to validate that a client has a valid connection with a remote PostgreSQL database. It can be ran from any node where the PostgreSQL client software is installed to validate connectivity before commencing other dependent tasks in your Puppet manifests, so it is often used when chained to other tasks such as: starting an application server, performing a database migration.

Example usage:

    postgresql::validate_db_connection { 'validate my postgres connection':
      database_host           => 'my.postgres.host',
      database_username       => 'mydbuser',
      database_password       => 'mydbpassword',
      database_name           => 'mydbname',
    }->
    exec { 'rake db:migrate':
      cwd => '/opt/myrubyapp',
    }

####`namevar`
Uniquely identify this resource, but functionally does nothing.

####`database_host`
The hostname of the database you wish to test. Defaults to 'undef' which generally uses the designated local unix socket.

####`database_port`
Port to use when connecting. Default to 'undef' which generally defaults to 5432 depending on your PostgreSQL packaging.

####`database_name`
The name of the database you wish to test. Defaults to 'postgres'.

####`database_username`
Username to connect with. Defaults to 'undef', which when using a unix socket and ident auth will be the user you are running as. If the host is remote you must provide a username.

####`database_password`
Password to connect with. Can be left blank, but that is not recommended.

####`run_as`
The user to run the `psql` command with for authenticiation. This is important when trying to connect to a database locally using Unix sockets and `ident` authentication. It is not needed for remote testing.

####`sleep`
Upon failure, sets the number of seconds to sleep for before trying again.

####`tries`
Upon failure, sets the number of attempts before giving up and failing the resource.

####`create_db_first`
This will ensure the database is created before running the test. This only really works if your test is local. Defaults to `true`.


###Function: postgresql\_password
If you need to generate a postgres encrypted password, use `postgresql_password`. You can call it from your production manifests if you don't mind them containing the clear text versions of your passwords, or you can call it from the command line and then copy and paste the encrypted password into your manifest:

    $ puppet apply --execute 'notify { "test": message => postgresql_password("username", "password") }'

###Function: postgresql\_acls\_to\_resources\_hash(acl\_array, id, order\_offset)
This internal function converts a list of `pg_hba.conf` based acls (passed in as an array of strings) to a format compatible with the `postgresql::pg_hba_rule` resource.

**This function should only be used internally by the module**.

Limitations
------------

Works with versions of PostgreSQL from 8.1 through 9.2.

Current it is only actively tested with the following operating systems:

* Debian 6.x and 7.x
* Centos 5.x, 6.x, and 7.x.
* Ubuntu 10.04 and 12.04, 14.04

Although patches are welcome for making it work with other OS distros, it is considered best effort.

### Postgis support

Postgis is currently considered an unsupported feature as it doesn't work on
all platforms correctly.

### All versions of RHEL/Centos

If you have selinux enabled you must add any custom ports you use to the postgresql_port_t context.  You can do this as follows:

```
# semanage port -a -t postgresql_port_t -p tcp $customport
```

Development
------------

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)

### Tests

There are two types of tests distributed with the module. Unit tests with rspec-puppet and system tests using rspec-system.

For unit testing, make sure you have:

* rake
* bundler

Install the necessary gems:

    bundle install --path=vendor

And then run the unit tests:

    bundle exec rake spec

The unit tests are ran in Travis-CI as well, if you want to see the results of your own tests register the service hook through Travis-CI via the accounts section for your Github clone of this project.

If you want to run the system tests, make sure you also have:

* vagrant > 1.2.x
* Virtualbox > 4.2.10

Then run the tests using:

    bundle exec rspec spec/acceptance

To run the tests on different operating systems, see the sets available in .nodeset.yml and run the specific set with the following syntax:

    RSPEC_SET=debian-607-x64 bundle exec rspec spec/acceptance

Transfer Notice
----------------

This Puppet module was originally authored by Inkling Systems. The maintainer preferred that Puppet Labs take ownership of the module for future improvement and maintenance as Puppet Labs is using it in the PuppetDB module.  Existing pull requests and issues were transferred over, please fork and continue to contribute here instead of Inkling.

Previously: [https://github.com/inkling/puppet-postgresql](https://github.com/inkling/puppet-postgresql)

Contributors
------------

 * Andrew Moon
 * [Kenn Knowles](https://github.com/kennknowles) ([@kennknowles](https://twitter.com/KennKnowles))
 * Adrien Thebo
 * Albert Koch
 * Andreas Ntaflos
 * Bret Comnes
 * Brett Porter
 * Chris Price
 * dharwood
 * Etienne Pelletier
 * Florin Broasca
 * Henrik
 * Hunter Haugen
 * Jari Bakken
 * Jordi Boggiano
 * Ken Barber
 * nzakaria
 * Richard Arends
 * Spenser Gilliland
 * stormcrow
 * William Van Hevelingen
