#apache

####Table of Contents

1. [Overview - What is the apache module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with apache](#setup)
    * [Beginning with apache - Installation](#beginning-with-apache)
    * [Configure a virtual host - Basic options for getting started](#configure-a-virtual-host)
4. [Usage - The classes and defined types available for configuration](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
        * [Class: apache](#class-apache)
        * [Defined Type: apache::custom_config](#defined-type-apachecustom_config)
        * [Class: apache::default_mods](#class-apachedefault_mods)
        * [Defined Type: apache::mod](#defined-type-apachemod)
        * [Classes: apache::mod::*](#classes-apachemodname)
        * [Class: apache::mod::alias](#class-apachemodalias)
        * [Class: apache::mod::event](#class-apachemodevent)
        * [Class: apache::mod::info](#class-apachemodinfo)
        * [Class: apache::mod::pagespeed](#class-apachemodpagespeed)
        * [Class: apache::mod::php](#class-apachemodphp)
        * [Class: apache::mod::ssl](#class-apachemodssl)
        * [Class: apache::mod::status](#class-apachemodstatus)
        * [Class: apache::mod::wsgi](#class-apachemodwsgi)
        * [Class: apache::mod::fcgid](#class-apachemodfcgid)
        * [Class: apache::mod::negotiation](#class-apachemodnegotiation)
        * [Class: apache::mod::deflate](#class-apachemoddeflate)
        * [Class: apache::mod::reqtimeout](#class-apachemodreqtimeout)
        * [Class: apache::mod::security](#class-modsecurity)
        * [Class: apache::mod::version](#class-apachemodversion)
        * [Defined Type: apache::vhost](#defined-type-apachevhost)
        * [Parameter: `directories` for apache::vhost](#parameter-directories-for-apachevhost)
        * [SSL parameters for apache::vhost](#ssl-parameters-for-apachevhost)
        * [Defined Type: apache::fastcgi::server](#defined-type-fastcgi-server)
    * [Virtual Host Examples - Demonstrations of some configuration options](#virtual-host-examples)
    * [Load Balancing](#load-balancing)
        * [Defined Type: apache::balancer](#defined-type-apachebalancer)
        * [Defined Type: apache::balancermember](#defined-type-apachebalancermember)
        * [Examples - Load balancing with exported and non-exported resources](#examples)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
        * [Public Classes](#public-classes)
        * [Private Classes](#private-classes)
    * [Defined Types](#defined-types)
        * [Public Defined Types](#public-defined-types)
        * [Private Defined Types](#private-defined-types)
    * [Templates](#templates)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
    * [Contributing to the apache module](#contributing)
    * [Running tests - A quick guide](#running-tests)

##Overview

The apache module allows you to set up virtual hosts and manage web services with minimal effort.

##Module Description

Apache is a widely-used web server, and this module provides a simplified way of creating configurations to manage your infrastructure. This includes the ability to configure and manage a range of different virtual host setups, as well as a streamlined way to install and configure Apache modules.

##Setup

**What apache affects:**

* configuration files and directories (created and written to)
    * **WARNING**: Configurations that are *not* managed by Puppet will be purged.
* package/service/configuration files for Apache
* Apache modules
* virtual hosts
* listened-to ports
* `/etc/make.conf` on FreeBSD and Gentoo
* depends on module 'gentoo/puppet-portage' for Gentoo

###Beginning with Apache

To install Apache with the default parameters

```puppet
    class { 'apache':  }
```

The defaults are determined by your operating system (e.g. Debian systems have one set of defaults, and RedHat systems have another, as do FreeBSD and Gentoo systems). These defaults work well in a testing environment, but are not suggested for production. To establish customized parameters

```puppet
    class { 'apache':
      default_mods        => false,
      default_confd_files => false,
    }
```

###Configure a virtual host

Declaring the `apache` class creates a default virtual host by setting up a vhost on port 80, listening on all interfaces and serving `$apache::docroot`.

```puppet
    class { 'apache': }
```

To configure a very basic, name-based virtual host

```puppet
    apache::vhost { 'first.example.com':
      port    => '80',
      docroot => '/var/www/first',
    }
```

*Note:* The default priority is 15. If nothing matches this priority, the alphabetically first name-based vhost is used. This is also true if you pass a higher priority and no names match anything else.

A slightly more complicated example, changes the docroot owner/group from the default 'root'

```puppet
    apache::vhost { 'second.example.com':
      port          => '80',
      docroot       => '/var/www/second',
      docroot_owner => 'third',
      docroot_group => 'third',
    }
```

To set up a virtual host with SSL and default SSL certificates

```puppet
    apache::vhost { 'ssl.example.com':
      port    => '443',
      docroot => '/var/www/ssl',
      ssl     => true,
    }
```

To set up a virtual host with SSL and specific SSL certificates

```puppet
    apache::vhost { 'fourth.example.com':
      port     => '443',
      docroot  => '/var/www/fourth',
      ssl      => true,
      ssl_cert => '/etc/ssl/fourth.example.com.cert',
      ssl_key  => '/etc/ssl/fourth.example.com.key',
    }
```

Virtual hosts listen on '*' by default. To listen on a specific IP address

```puppet
    apache::vhost { 'subdomain.example.com':
      ip      => '127.0.0.1',
      port    => '80',
      docroot => '/var/www/subdomain',
    }
```

To set up a virtual host with a wildcard alias for the subdomain mapped to a same-named directory, for example: `http://example.com.loc` to `/var/www/example.com`

```puppet
    apache::vhost { 'subdomain.loc':
      vhost_name       => '*',
      port             => '80',
      virtual_docroot  => '/var/www/%-2+',
      docroot          => '/var/www',
      serveraliases    => ['*.loc',],
    }
```

To set up a virtual host with suPHP

```puppet
    apache::vhost { 'suphp.example.com':
      port                => '80',
      docroot             => '/home/appuser/myphpapp',
      suphp_addhandler    => 'x-httpd-php',
      suphp_engine        => 'on',
      suphp_configpath    => '/etc/php5/apache2',
      directories         => { path => '/home/appuser/myphpapp',
        'suphp'           => { user => 'myappuser', group => 'myappgroup' },
      }
    }
```

To set up a virtual host with WSGI

```puppet
    apache::vhost { 'wsgi.example.com':
      port                        => '80',
      docroot                     => '/var/www/pythonapp',
      wsgi_application_group      => '%{GLOBAL}',
      wsgi_daemon_process         => 'wsgi',
      wsgi_daemon_process_options => {
        processes    => '2',
        threads      => '15',
        display-name => '%{GROUP}',
       },
      wsgi_import_script          => '/var/www/demo.wsgi',
      wsgi_import_script_options  =>
        { process-group => 'wsgi', application-group => '%{GLOBAL}' },
      wsgi_process_group          => 'wsgi',
      wsgi_script_aliases         => { '/' => '/var/www/demo.wsgi' },
    }
```

Starting in Apache 2.2.16, HTTPD supports [FallbackResource](https://httpd.apache.org/docs/current/mod/mod_dir.html#fallbackresource), a simple replacement for common RewriteRules.

```puppet
    apache::vhost { 'wordpress.example.com':
      port                => '80',
      docroot             => '/var/www/wordpress',
      fallbackresource    => '/index.php',
    }
```

Please note that the 'disabled' argument to FallbackResource is only supported since Apache 2.2.24.

See a list of all [virtual host parameters](#defined-type-apachevhost). See an extensive list of [virtual host examples](#virtual-host-examples).

##Usage

###Classes and Defined Types

This module modifies Apache configuration files and directories and purges any configuration not managed by Puppet. Configuration of Apache should be managed by Puppet, as non-Puppet configuration files can cause unexpected failures.

It is possible to temporarily disable full Puppet management by setting the [`purge_configs`](#purge_configs) parameter within the base `apache` class to 'false'. This option should only be used as a temporary means of saving and relocating customized configurations. See the [`purge_configs` parameter](#purge_configs) for more information.

####Class: `apache`

The apache module's primary class, `apache`, guides the basic setup of Apache on your system.

You can establish a default vhost in this class, the `vhost` class, or both. You can add additional vhost configurations for specific virtual hosts using a declaration of the `vhost` type.

**Parameters within `apache`:**

#####`allow_encoded_slashes`

This sets the server default for the [`AllowEncodedSlashes` declaration](http://httpd.apache.org/docs/current/mod/core.html#allowencodedslashes) which modifies the responses to URLs with `\` and `/` characters. The default is undefined, which omits the declaration from the server configuration and select the Apache default setting of `Off`. Allowed values are: `on`, `off` or `nodecode`.

#####`apache_version`

Configures the behavior of the module templates, package names, and default mods by setting the Apache version. Default is determined by the class `apache::version` using the OS family and release. It should not be configured manually without special reason.

#####`conf_dir`

Changes the location of the configuration directory the main configuration file is placed in. Defaults to '/etc/httpd/conf' on RedHat, '/etc/apache2' on Debian, '/usr/local/etc/apache22' on FreeBSD, and '/etc/apache2' on Gentoo.

#####`confd_dir`

Changes the location of the configuration directory your custom configuration files are placed in. Defaults to '/etc/httpd/conf' on RedHat, '/etc/apache2/conf.d' on Debian, '/usr/local/etc/apache22' on FreeBSD, and '/etc/apache2/conf.d' on Gentoo.

#####`conf_template`

Overrides the template used for the main apache configuration file. Defaults to 'apache/httpd.conf.erb'.

*Note:* Using this parameter is potentially risky, as the module has been built for a minimal configuration file with the configuration primarily coming from conf.d/ entries.

#####`default_charset`

If defined, the value will be set as `AddDefaultCharset` in the main configuration file. It is undefined by default.

#####`default_confd_files`

Generates default set of include-able Apache configuration files under  `${apache::confd_dir}` directory. These configuration files correspond to what is usually installed with the Apache package on a given platform.

#####`default_mods`

Sets up Apache with default settings based on your OS. Valid values are 'true', 'false', or an array of mod names.

Defaults to 'true', which includes the default [HTTPD mods](https://github.com/puppetlabs/puppetlabs-apache/blob/master/manifests/default_mods.pp).

If false, it only includes the mods required to make HTTPD work, and any other mods can be declared on their own.

If an array, the apache module includes the array of mods listed.

#####`default_ssl_ca`

The default certificate authority, which is automatically set to 'undef'. This default works out of the box but must be updated with your specific certificate information before being used in production.

#####`default_ssl_cert`

The default SSL certification, which is automatically set based on your operating system  ('/etc/pki/tls/certs/localhost.crt' for RedHat, '/etc/ssl/certs/ssl-cert-snakeoil.pem' for Debian, '/usr/local/etc/apache22/server.crt' for FreeBSD, and '/etc/ssl/apache2/server.crt' for Gentoo). This default works out of the box but must be updated with your specific certificate information before being used in production.

#####`default_ssl_chain`

The default SSL chain, which is automatically set to 'undef'. This default works out of the box but must be updated with your specific certificate information before being used in production.

#####`default_ssl_crl`

The default certificate revocation list to use, which is automatically set to 'undef'. This default works out of the box but must be updated with your specific certificate information before being used in production.

#####`default_ssl_crl_path`

The default certificate revocation list path, which is automatically set to 'undef'. This default works out of the box but must be updated with your specific certificate information before being used in production.

#####`default_ssl_crl_check`

Sets the default certificate revocation check level via the [SSLCARevocationCheck directive](http://httpd.apache.org/docs/current/mod/mod_ssl.html#sslcarevocationcheck), which is automatically set to 'undef'. This default works out of the box but must be specified when using CRLs in production. Only applicable to Apache 2.4 or higher, the value is ignored on older versions.

#####`default_ssl_key`

The default SSL key, which is automatically set based on your operating system ('/etc/pki/tls/private/localhost.key' for RedHat, '/etc/ssl/private/ssl-cert-snakeoil.key' for Debian, '/usr/local/etc/apache22/server.key' for FreeBSD, and '/etc/ssl/apache2/server.key' for Gentoo). This default works out of the box but must be updated with your specific certificate information before being used in production.

#####`default_ssl_vhost`

Sets up a default SSL virtual host. Defaults to 'false'. If set to 'true', sets up the following vhost:

```puppet
    apache::vhost { 'default-ssl':
      port            => 443,
      ssl             => true,
      docroot         => $docroot,
      scriptalias     => $scriptalias,
      serveradmin     => $serveradmin,
      access_log_file => "ssl_${access_log_file}",
      }
```

SSL vhosts only respond to HTTPS queries.

#####`default_type`

(Apache httpd 2.2 only) MIME content-type that will be sent if the server cannot determine a type in any other way. This directive has been deprecated in Apache httpd 2.4, and only exists there for backwards compatibility of configuration files.

#####`default_vhost`

Sets up a default virtual host. Defaults to 'true', set to 'false' to set up [customized virtual hosts](#configure-a-virtual-host).

#####`docroot`

Changes the location of the default [Documentroot](https://httpd.apache.org/docs/current/mod/core.html#documentroot). Defaults to '/var/www/html' on RedHat, '/var/www' on Debian, '/usr/local/www/apache22/data' on FreeBSD, and '/var/www/localhost/htdocs' on Gentoo.

#####`error_documents`

Enables custom error documents. Defaults to 'false'.

#####`httpd_dir`

Changes the base location of the configuration directories used for the apache service. This is useful for specially repackaged HTTPD builds, but might have unintended consequences when used in combination with the default distribution packages. Defaults to '/etc/httpd' on RedHat, '/etc/apache2' on Debian, '/usr/local/etc/apache22' on FreeBSD, and '/etc/apache2' on Gentoo.

#####`keepalive`

Enables persistent connections.

#####`keepalive_timeout`

Sets the amount of time the server waits for subsequent requests on a persistent connection. Defaults to '15'.

#####`max_keepalive_requests`

Sets the limit of the number of requests allowed per connection when KeepAlive is on. Defaults to '100'.

#####`loadfile_name`

Sets the file name for the module loadfile. Should be in the format *.load.  This can be used to set the module load order.

#####`log_level`

Changes the verbosity level of the error log. Defaults to 'warn'. Valid values are 'emerg', 'alert', 'crit', 'error', 'warn', 'notice', 'info', or 'debug'.

#####`log_formats`

Define additional [LogFormats](https://httpd.apache.org/docs/current/mod/mod_log_config.html#logformat). This is done in a Hash:

```puppet
  $log_formats = { vhost_common => '%v %h %l %u %t \"%r\" %>s %b' }
```

#####`logroot`

Changes the directory where Apache log files for the virtual host are placed. Defaults to '/var/log/httpd' on RedHat, '/var/log/apache2' on Debian, '/var/log/apache22' on FreeBSD, and '/var/log/apache2' on Gentoo.

#####`logroot_mode`

Overrides the mode the default logroot directory is set to ($::apache::logroot). Defaults to undef. Do NOT give people write access to the directory the logs are stored
in without being aware of the consequences; see http://httpd.apache.org/docs/2.4/logs.html#security for details.

#####`manage_group`

Setting this to 'false' stops the group resource from being created. This is for when you have a group, created from another Puppet module, you want to use to run Apache. Without this parameter, attempting to use a previously established group would result in a duplicate resource error.

#####`manage_user`

Setting this to 'false' stops the user resource from being created. This is for instances when you have a user, created from another Puppet module, you want to use to run Apache. Without this parameter, attempting to use a previously established user would result in a duplicate resource error.

#####`mod_dir`

Changes the location of the configuration directory your Apache modules configuration files are placed in. Defaults to '/etc/httpd/conf.d' for RedHat, '/etc/apache2/mods-available' for Debian, '/usr/local/etc/apache22/Modules' for FreeBSD, and '/etc/apache2/modules.d' on Gentoo.

#####`mpm_module`

Determines which MPM is loaded and configured for the HTTPD process. Valid values are 'event', 'itk', 'peruser', 'prefork', 'worker', or 'false'. Defaults to 'prefork' on RedHat, FreeBSD and Gentoo, and 'worker' on Debian. Must be set to 'false' to explicitly declare the following classes with custom parameters:

* `apache::mod::event`
* `apache::mod::itk`
* `apache::mod::peruser`
* `apache::mod::prefork`
* `apache::mod::worker`

*Note:* Switching between different MPMs on FreeBSD is possible but quite difficult. Before changing `$mpm_module` you must uninstall all packages that depend on your currently-installed Apache.

#####`package_ensure`

Allows control over the package ensure attribute. Can be 'present','absent', or a version string.

#####`ports_file`

Changes the name of the file containing Apache ports configuration. Default is `${conf_dir}/ports.conf`.

#####`purge_configs`

Removes all other Apache configs and vhosts, defaults to 'true'. Setting this to 'false' is a stopgap measure to allow the apache module to coexist with existing or otherwise-managed configuration. It is recommended that you move your configuration entirely to resources within this module.

#####`purge_vhost_configs`

If `vhost_dir` != `confd_dir`, this controls the removal of any configurations that are not managed by Puppet within `vhost_dir`. It defaults to the value of `purge_configs`. Setting this to false is a stopgap measure to allow the apache module to coexist with existing or otherwise unmanaged configurations within `vhost_dir`

#####`sendfile`

Makes Apache use the Linux kernel sendfile to serve static files. Defaults to 'On'.

#####`serveradmin`

Sets the server administrator. Defaults to 'root@localhost'.

#####`servername`

Sets the server name. Defaults to `fqdn` provided by Facter.

#####`server_root`

Sets the root directory in which the server resides. Defaults to '/etc/httpd' on RedHat, '/etc/apache2' on Debian, '/usr/local' on FreeBSD, and '/var/www' on Gentoo.

#####`server_signature`

Configures a trailing footer line under server-generated documents. More information about [ServerSignature](http://httpd.apache.org/docs/current/mod/core.html#serversignature). Defaults to 'On'.

#####`server_tokens`

Controls how much information Apache sends to the browser about itself and the operating system. More information about [ServerTokens](http://httpd.apache.org/docs/current/mod/core.html#servertokens). Defaults to 'OS'.

#####`service_enable`

Determines whether the HTTPD service is enabled when the machine is booted. Defaults to 'true'.

#####`service_ensure`

Determines whether the service should be running. Valid values are 'true', 'false', 'running', or 'stopped' when Puppet should manage the service. Any other value sets ensure to 'false' for the Apache service, which is useful when you want to let the service be managed by some other application like Pacemaker. Defaults to 'running'.

#####`service_name`

Name of the Apache service to run. Defaults to: 'httpd' on RedHat, 'apache2' on Debian and Gentoo, and 'apache22' on FreeBSD.

#####`service_manage`

Determines whether the HTTPD service state is managed by Puppet . Defaults to 'true'.

#####`trace_enable`

Controls how TRACE requests per RFC 2616 are handled. More information about [TraceEnable](http://httpd.apache.org/docs/current/mod/core.html#traceenable). Defaults to 'On'.

#####`vhost_dir`

Changes the location of the configuration directory your virtual host configuration files are placed in. Defaults to 'etc/httpd/conf.d' on RedHat, '/etc/apache2/sites-available' on Debian, '/usr/local/etc/apache22/Vhosts' on FreeBSD, and '/etc/apache2/vhosts.d' on Gentoo.

#####`apache_name`

The name of the Apache package to install. This is automatically detected in `::apache::params`. You might need to override this if you are using a non-standard Apache package, such as those from Red Hat's software collections.

####Defined Type: `apache::custom_config`

Allows you to create custom configs for Apache. The configuration files are only added to the Apache confd dir if the file is valid. An error is raised during the Puppet run if the file is invalid and `$verify_config` is `true`.

```puppet
    apache::custom_config { 'test':
        content => '# Test',
    }
```

**Parameters within `apache::custom_config`:**

#####`ensure`

Specify whether the configuration file is present or absent. Defaults to 'present'. Valid values are 'present' and 'absent'.

#####`confdir`

The directory to place the configuration file in. Defaults to `$::apache::confd_dir`.

#####`content`

The content of the configuration file. Only one of `$content` and `$source` can be specified.

#####`priority`

The priority of the configuration file, used for ordering. Defaults to '25'.

Pass priority `false` to omit the priority prefix in file names.

#####`source`

The source of the configuration file. Only one of `$content` and `$source` can be specified.

#####`verify_command`

The command to use to verify the configuration file. It should use a fully qualified command. Defaults to '/usr/sbin/apachectl -t'. The `$verify_command` is only used if `$verify_config` is `true`. If the `$verify_command` fails, the configuration file is deleted, the Apache service is not notified, and an error is raised during the Puppet run.

#####`verify_config`

Boolean to specify whether the configuration file should be validated before the Apache service is notified. Defaults to `true`.

####Class: `apache::default_mods`

Installs default Apache modules based on what OS you are running.

```puppet
    class { 'apache::default_mods': }
```

####Defined Type: `apache::mod`

Used to enable arbitrary Apache HTTPD modules for which there is no specific `apache::mod::[name]` class. The `apache::mod` defined type also installs the required packages to enable the module, if any.

```puppet
    apache::mod { 'rewrite': }
    apache::mod { 'ldap': }
```

####Classes: `apache::mod::[name]`

There are many `apache::mod::[name]` classes within this module that can be declared using `include`:

* `actions`
* `alias`(see [`apache::mod::alias`](#class-apachemodalias) below)
* `auth_basic`
* `auth_cas`* (see [`apache::mod::auth_cas`](#class-apachemodauthcas) below)
* `auth_kerb`
* `authn_file`
* `authnz_ldap`*
* `authz_default`
* `authz_user`
* `autoindex`
* `cache`
* `cgi`
* `cgid`
* `dav`
* `dav_fs`
* `dav_svn`*
* `deflate`
* `dev`
* `dir`*
* `disk_cache`
* `event`(see [`apache::mod::event`](#class-apachemodevent) below)
* `expires`
* `fastcgi`
* `fcgid`
* `filter`
* `headers`
* `include`
* `info`*
* `itk`
* `ldap`
* `mime`
* `mime_magic`*
* `negotiation`
* `nss`*
* `pagespeed` (see [`apache::mod::pagespeed`](#class-apachemodpagespeed) below)
* `passenger`*
* `perl`
* `peruser`
* `php` (requires [`mpm_module`](#mpm_module) set to `prefork`)
* `prefork`*
* `proxy`*
* `proxy_ajp`
* `proxy_balancer`
* `proxy_html`
* `proxy_http`
* `python`
* `reqtimeout`
* `rewrite`
* `rpaf`*
* `setenvif`
* `security`
* `shib`* (see [`apache::mod::shib`](#class-apachemodshib) below)
* `speling`
* `ssl`* (see [`apache::mod::ssl`](#class-apachemodssl) below)
* `status`* (see [`apache::mod::status`](#class-apachemodstatus) below)
* `suphp`
* `userdir`*
* `vhost_alias`
* `worker`*
* `wsgi` (see [`apache::mod::wsgi`](#class-apachemodwsgi) below)
* `xsendfile`

Modules noted with a * indicate that the module has settings and, thus, a template that includes parameters. These parameters control the module's configuration. Most of the time, these parameters do not require any configuration or attention.

The modules mentioned above, and other Apache modules that have templates, cause template files to be dropped along with the mod install. The module will not work without the template. Any module without a template installs the package but drops no files.

###Class: `apache::mod::alias`

Installs and manages the alias module.

Full Documentation for alias is available from [Apache](https://httpd.apache.org/docs/current/mod/mod_alias.html).

To disable directory listing for the icons directory:
```puppet
  class { 'apache::mod::alias':
    icons_options => 'None',
  }
```

####Class:  `apache::mod::event`

Installs and manages mpm_event module.

Full Documentation for mpm_event is available from [Apache](https://httpd.apache.org/docs/current/mod/event.html).

To configure the event thread limit:

```puppet
  class {'apache::mod::event':
    $threadlimit      => '128',
  }
```

####Class: `apache::mod::auth_cas`

Installs and manages mod_auth_cas. The parameters `cas_login_url` and `cas_validate_url` are required.

Full documentation on mod_auth_cas is available from [JASIG](https://github.com/Jasig/mod_auth_cas).

####Class: `apache::mod::info`

Installs and manages mod_info which provides a comprehensive overview of the server configuration.

Full documentation for mod_info is available from [Apache](https://httpd.apache.org/docs/current/mod/mod_info.html).

These are the default settings:

```puppet
  $allow_from      = ['127.0.0.1','::1'],
  $apache_version  = $::apache::apache_version,
  $restrict_access = true,
```

To set the addresses that are allowed to access /server-info add the following:

```puppet
  class {'apache::mod::info':
    allow_from      => [
      '10.10.36',
      '10.10.38',
      '127.0.0.1',
    ],
  }
```

To disable the access restrictions add the following:

```puppet
  class {'apache::mod::info':
    restrict_access => false,
  }
```

It is not recommended to leave this set to false though it can be very useful for testing. For this reason, you can insert this setting in your normal code to temporarily disable the restrictions like so:

```puppet
  class {'apache::mod::info':
    restrict_access => false, # false disables the block below
    allow_from      => [
      '10.10.36',
      '10.10.38',
      '127.0.0.1',
    ],
  }
```

####Class: `apache::mod::pagespeed`

Installs and manages mod_pagespeed, which is a Google module that rewrites web pages to reduce latency and bandwidth.

This module does *not* manage the software repositories needed to automatically install the
mod-pagespeed-stable package. The module does however require that the package be installed,
or be installable using the system's default package provider.  You should ensure that this
pre-requisite is met or declaring `apache::mod::pagespeed` causes the Puppet run to fail.

These are the defaults:

```puppet
    class { 'apache::mod::pagespeed':
      inherit_vhost_config          => 'on',
      filter_xhtml                  => false,
      cache_path                    => '/var/cache/mod_pagespeed/',
      log_dir                       => '/var/log/pagespeed',
      memcache_servers              => [],
      rewrite_level                 => 'CoreFilters',
      disable_filters               => [],
      enable_filters                => [],
      forbid_filters                => [],
      rewrite_deadline_per_flush_ms => 10,
      additional_domains            => undef,
      file_cache_size_kb            => 102400,
      file_cache_clean_interval_ms  => 3600000,
      lru_cache_per_process         => 1024,
      lru_cache_byte_limit          => 16384,
      css_flatten_max_bytes         => 2048,
      css_inline_max_bytes          => 2048,
      css_image_inline_max_bytes    => 2048,
      image_inline_max_bytes        => 2048,
      js_inline_max_bytes           => 2048,
      css_outline_min_bytes         => 3000,
      js_outline_min_bytes          => 3000,
      inode_limit                   => 500000,
      image_max_rewrites_at_once    => 8,
      num_rewrite_threads           => 4,
      num_expensive_rewrite_threads => 4,
      collect_statistics            => 'on',
      statistics_logging            => 'on',
      allow_view_stats              => [],
      allow_pagespeed_console       => [],
      allow_pagespeed_message       => [],
      message_buffer_size           => 100000,
      additional_configuration      => { }
    }
```

Full documentation for mod_pagespeed is available from [Google](http://modpagespeed.com).

####Class: `apache::mod::php`

Installs and configures mod_php. The defaults are OS-dependant.

Overriding the package name:
```puppet
  class {'::apache::mod::php':
    package_name => "php54-php",
    path         => "${::apache::params::lib_path}/libphp54-php5.so",
  }
```

Overriding the default configuartion:
```puppet
  class {'::apache::mod::php':
    source => 'puppet:///modules/apache/my_php.conf',
  }
```

or
```puppet
  class {'::apache::mod::php':
    template => 'apache/php.conf.erb',
  }
```

or

```puppet
  class {'::apache::mod::php':
    content => '
AddHandler php5-script .php
AddType text/html .php',
  }
```
####Class: `apache::mod::shib`

Installs the [Shibboleth](http://shibboleth.net/) module for Apache which allows the use of SAML2 Single-Sign-On (SSO) authentication by Shibboleth Identity Providers and Shibboleth Federations. This class only installs and configures the Apache components of a Shibboleth Service Provider (a web application that consumes Shibboleth SSO identities). The Shibboleth configuration can be managed manually, with Puppet, or using a [Shibboleth Puppet Module](https://github.com/aethylred/puppet-shibboleth).

Defining this class enables the Shibboleth specific parameters in `apache::vhost` instances.

####Class: `apache::mod::ssl`

Installs Apache SSL capabilities and uses the ssl.conf.erb template. These are the defaults:

```puppet
    class { 'apache::mod::ssl':
      ssl_compression         => false,
      ssl_cryptodevice        => 'builtin',
      ssl_options             => [ 'StdEnvVars' ],
      ssl_cipher              => 'HIGH:MEDIUM:!aNULL:!MD5',
      ssl_honorcipherorder    => 'On',
      ssl_protocol            => [ 'all', '-SSLv2', '-SSLv3' ],
      ssl_pass_phrase_dialog  => 'builtin',
      ssl_random_seed_bytes   => '512',
      ssl_sessioncachetimeout => '300',
    }
```

To *use* SSL with a virtual host, you must either set the`default_ssl_vhost` parameter in `::apache` to 'true' or set the `ssl` parameter in `apache::vhost` to 'true'.

####Class: `apache::mod::status`

Installs Apache mod_status and uses the status.conf.erb template. These are the defaults:

```puppet
    class { 'apache::mod::status':
      allow_from      = ['127.0.0.1','::1'],
      extended_status = 'On',
      status_path     = '/server-status',
){


  }
```

####Class: `apache::mod::wsgi`

Enables Python support in the WSGI module. To use, simply `include 'apache::mod::wsgi'`.

For customized parameters, which tell Apache how Python is currently configured on the operating system,

```puppet
    class { 'apache::mod::wsgi':
      wsgi_socket_prefix => "\${APACHE_RUN_DIR}WSGI",
      wsgi_python_home   => '/path/to/venv',
      wsgi_python_path   => '/path/to/venv/site-packages',
    }
```

To specify an alternate mod\_wsgi package name to install and the name of the module .so it provides,
(e.g. a "python27-mod\_wsgi" package that provides "python27-mod_wsgi.so" in the default module directory):

```puppet
    class { 'apache::mod::wsgi':
      wsgi_socket_prefix => "\${APACHE_RUN_DIR}WSGI",
      wsgi_python_home   => '/path/to/venv',
      wsgi_python_path   => '/path/to/venv/site-packages',
	  package_name       => 'python27-mod_wsgi',
	  mod_path           => 'python27-mod_wsgi.so',
    }
```

If ``mod_path`` does not contain "/", it will be prefixed by the default module path
for your OS; otherwise, it will be used literally.

More information about [WSGI](http://modwsgi.readthedocs.org/en/latest/).

####Class: `apache::mod::fcgid`

Installs and configures mod_fcgid.

The class makes no effort to list all available options, but rather uses an options hash to allow for ultimate flexibility:

```puppet
    class { 'apache::mod::fcgid':
      options => {
        'FcgidIPCDir'  => '/var/run/fcgidsock',
        'SharememPath' => '/var/run/fcgid_shm',
        'AddHandler'   => 'fcgid-script .fcgi',
      },
    }
```

For a full list op options, see the [official mod_fcgid documentation](https://httpd.apache.org/mod_fcgid/mod/mod_fcgid.html).

It is also possible to set the FcgidWrapper per directory per vhost. You must ensure the fcgid module is loaded because there is no auto loading.

```puppet
    include apache::mod::fcgid
    apache::vhost { 'example.org':
      docroot     => '/var/www/html',
      directories => {
        path        => '/var/www/html',
        fcgiwrapper => {
          command => '/usr/local/bin/fcgiwrapper',
        }
      },
    }
```

See [FcgidWrapper documentation](https://httpd.apache.org/mod_fcgid/mod/mod_fcgid.html#fcgidwrapper) for more information.

####Class: `apache::mod::negotiation`

Installs and configures mod_negotiation. If there are not provided any
parameter, default apache mod_negotiation configuration is done.

```puppet
  class { '::apache::mod::negotiation':
    force_language_priority => 'Prefer',
    language_priority       => [ 'es', 'en', 'ca', 'cs', 'da', 'de', 'el', 'eo' ],
  }
```

**Parameters within `apache::mod::negotiation`:**

#####`force_language_priority`

A string that sets the `ForceLanguagePriority` option. Defaults to `Prefer Fallback`.

#####`language_priority`

An array of languages to set the `LanguagePriority` option of the module.

####Class: `apache::mod::deflate`

Installs and configures mod_deflate. If no parameters are provided, a default configuration is applied.

```puppet
  class { '::apache::mod::deflate':
    types => [ 'text/html', 'text/css' ],
    notes => {
      'Input' => 'instream',
      'Ratio' => 'ratio',
    },
  }
```

#####`types`

An array of mime types to be deflated.

#####`notes`

A hash where the key represents the type and the value represents the note name.


####Class: `apache::mod::reqtimeout`

Installs and configures mod_reqtimeout. Defaults to recommended apache
mod_reqtimeout configuration.

```puppet
  class { '::apache::mod::reqtimeout':
    timeouts => ['header=20-40,MinRate=500', 'body=20,MinRate=500'],
  }
```

####Class: `apache::mod::version`

This wrapper around mod_version warns on Debian and Ubuntu systems with Apache httpd 2.4
about loading mod_version, as on these platforms it's already built-in.

```puppet
  include '::apache::mod::version'
```

#####`timeouts`

A string or an array that sets the `RequestReadTimeout` option. Defaults to
`['header=20-40,MinRate=500', 'body=20,MinRate=500']`.


####Class: `apache::mod::security`

Installs and configures mod_security.  Defaults to enabled and running on all
vhosts.

```puppet
  include '::apache::mod::security'
```

#####`crs_package`

Name of package to install containing crs rules

#####`modsec_dir`

Directory to install the modsec configuration and activated rules links into

#####`activated_rules`

Array of rules from the modsec_crs_path to activate by symlinking to
${modsec_dir}/activated_rules.

#####`allowed_methods`

HTTP methods allowed by mod_security

#####`content_types`

Content-types allowed by mod_security

#####`restricted_extensions`

Extensions prohibited by mod_security

#####`restricted_headers`

Headers restricted by mod_security


####Defined Type: `apache::vhost`

The Apache module allows a lot of flexibility in the setup and configuration of virtual hosts. This flexibility is due, in part, to `vhost` being a defined resource type, which allows it to be evaluated multiple times with different parameters.

The `vhost` defined type allows you to have specialized configurations for virtual hosts that have requirements outside the defaults. You can set up a default vhost within the base `::apache` class, as well as set a customized vhost as default. Your customized vhost (priority 10) will be privileged over the base class vhost (15).

The `vhost` defined type uses `concat::fragment` to build the configuration file, so if you want to inject custom fragments for pieces of the configuration not supported by default by the defined type, you can add a custom fragment.  For the `order` parameter for the custom fragment, the `vhost` defined type uses multiples of 10, so any order that isn't a multiple of 10 should work.

```puppet
    apache::vhost { "example.com":
      docroot  => '/var/www/html',
      priority => '25',
    }
    concat::fragment { "example.com-my_custom_fragment":
      target  => '25-example.com.conf',
      order   => 11,
      content => '# my custom comment',
    }
```

If you have a series of specific configurations and do not want a base `::apache` class default vhost, make sure to set the base class `default_vhost` to 'false'.

```puppet
    class { 'apache':
      default_vhost => false,
    }
```

**Parameters within `apache::vhost`:**

#####`access_log`

Specifies whether `*_access.log` directives (`*_file`,`*_pipe`, or `*_syslog`) should be configured. Setting the value to 'false' chooses none. Defaults to 'true'.

#####`access_log_file`

Sets the `*_access.log` filename that is placed in `$logroot`. Given a vhost, example.com, it defaults to 'example.com_ssl.log' for SSL vhosts and 'example.com_access.log' for non-SSL vhosts.

#####`access_log_pipe`

Specifies a pipe to send access log messages to. Defaults to 'undef'.

#####`access_log_syslog`

Sends all access log messages to syslog. Defaults to 'undef'.

#####`access_log_format`

Specifies the use of either a LogFormat nickname or a custom format string for the access log. Defaults to 'combined'. See [these examples](http://httpd.apache.org/docs/current/mod/mod_log_config.html).

#####`access_log_env_var`

Specifies that only requests with particular environment variables be logged. Defaults to 'undef'.

#####`add_default_charset`

Sets [AddDefaultCharset](http://httpd.apache.org/docs/current/mod/core.html#adddefaultcharset), a default value for the media charset, which is added to text/plain and text/html responses.

#####`add_listen`

Determines whether the vhost creates a Listen statement. The default value is 'true'.

Setting `add_listen` to 'false' stops the vhost from creating a Listen statement, and this is important when you combine vhosts that are not passed an `ip` parameter with vhosts that *are* passed the `ip` parameter.

#####`use_optional_includes`

Specifies if for apache > 2.4 it should use IncludeOptional instead of Include for `additional_includes`. Defaults to 'false'.

#####`additional_includes`

Specifies paths to additional static, vhost-specific Apache configuration files. Useful for implementing a unique, custom configuration not supported by this module. Can be an array. Defaults to '[]'.

#####`aliases`

Passes a list of hashes to the vhost to create Alias, AliasMatch, ScriptAlias or ScriptAliasMatch directives as per the [mod_alias documentation](http://httpd.apache.org/docs/current/mod/mod_alias.html). These hashes are formatted as follows:

```puppet
aliases => [
  { aliasmatch       => '^/image/(.*)\.jpg$',
    path             => '/files/jpg.images/$1.jpg',
  },
  { alias            => '/image',
    path             => '/ftp/pub/image',
  },
  { scriptaliasmatch => '^/cgi-bin(.*)',
    path             => '/usr/local/share/cgi-bin$1',
  },
  { scriptalias      => '/nagios/cgi-bin/',
    path             => '/usr/lib/nagios/cgi-bin/',
  },
  { alias            => '/nagios',
    path             => '/usr/share/nagios/html',
  },
],
```

For `alias`, `aliasmatch`, `scriptalias` and `scriptaliasmatch` to work, each needs a corresponding context, such as `<Directory /path/to/directory>` or `<Location /some/location/here>`. The directives are created in the order specified in the `aliases` parameter. As described in the [`mod_alias` documentation](http://httpd.apache.org/docs/current/mod/mod_alias.html), more specific `alias`, `aliasmatch`, `scriptalias` or `scriptaliasmatch` parameters should come before the more general ones to avoid shadowing.

*Note*: Using the `aliases` parameter is preferred over the `scriptaliases` parameter since here the order of the various alias directives among each other can be controlled precisely. Defining ScriptAliases using the `scriptaliases` parameter means *all* ScriptAlias directives will come after *all* Alias directives, which can lead to Alias directives shadowing ScriptAlias directives. This is often problematic, for example in case of Nagios.

*Note:* If `apache::mod::passenger` is loaded and `PassengerHighPerformance => true` is set, then Alias might have issues honoring the `PassengerEnabled => off` statement. See [this article](http://www.conandalton.net/2010/06/passengerenabled-off-not-working.html) for details.

#####`allow_encoded_slashes`

This sets the [`AllowEncodedSlashes` declaration](http://httpd.apache.org/docs/current/mod/core.html#allowencodedslashes) for the vhost, overriding the server default. This modifies the vhost responses to URLs with `\` and `/` characters. The default is undefined, which omits the declaration from the server configuration and select the Apache default setting of `Off`. Allowed values are: `on`, `off` or `nodecode`.

#####`block`

Specifies the list of things Apache blocks access to. The default is an empty set, '[]'. Currently, the only option is 'scm', which blocks web access to .svn, .git and .bzr directories.

#####`custom_fragment`

Passes a string of custom configuration directives to be placed at the end of the vhost configuration. Defaults to 'undef'.

#####`default_vhost`

Sets a given `apache::vhost` as the default to serve requests that do not match any other `apache::vhost` definitions. The default value is 'false'.

#####`directories`

See the [`directories` section](#parameter-directories-for-apachevhost).

#####`directoryindex`

Sets the list of resources to look for when a client requests an index of the directory by specifying a '/' at the end of the directory name. [DirectoryIndex](http://httpd.apache.org/docs/current/mod/mod_dir.html#directoryindex) has more information. Defaults to 'undef'.

#####`docroot`

Provides the
[DocumentRoot](http://httpd.apache.org/docs/current/mod/core.html#documentroot)
directive, which identifies the directory Apache serves files from. Required.

#####`docroot_group`

Sets group access to the docroot directory. Defaults to 'root'.

#####`docroot_owner`

Sets individual user access to the docroot directory. Defaults to 'root'.

#####`docroot_mode`

Sets access permissions of the docroot directory. Defaults to 'undef'.

#####`manage_docroot`

Whether to manage to docroot directory at all. Defaults to 'true'.

#####`error_log`

Specifies whether `*_error.log` directives should be configured. Defaults to 'true'.

#####`error_log_file`

Points to the `*_error.log` file. Given a vhost, example.com, it defaults to 'example.com_ssl_error.log' for SSL vhosts and 'example.com_access_error.log' for non-SSL vhosts.

#####`error_log_pipe`

Specifies a pipe to send error log messages to. Defaults to 'undef'.

#####`error_log_syslog`

Sends all error log messages to syslog. Defaults to 'undef'.

#####`error_documents`

A list of hashes which can be used to override the [ErrorDocument](https://httpd.apache.org/docs/current/mod/core.html#errordocument) settings for this vhost. Defaults to '[]'. Example:

```puppet
    apache::vhost { 'sample.example.net':
      error_documents => [
        { 'error_code' => '503', 'document' => '/service-unavail' },
        { 'error_code' => '407', 'document' => 'https://example.com/proxy/login' },
      ],
    }
```

#####`ensure`

Specifies if the vhost file is present or absent. Defaults to 'present'.

#####`fallbackresource`

Sets the [FallbackResource](http://httpd.apache.org/docs/current/mod/mod_dir.html#fallbackresource) directive, which specifies an action to take for any URL that doesn't map to anything in your filesystem and would otherwise return 'HTTP 404 (Not Found)'. Valid values must either begin with a / or be 'disabled'. Defaults to 'undef'.

#####`headers`

Adds lines to replace, merge, or remove response headers. See [Header](http://httpd.apache.org/docs/current/mod/mod_headers.html#header) for more information. Can be an array. Defaults to 'undef'.

#####`ip`

Sets the IP address the vhost listens on. Defaults to listen on all IPs.

#####`ip_based`

Enables an [IP-based](http://httpd.apache.org/docs/current/vhosts/ip-based.html) vhost. This parameter inhibits the creation of a NameVirtualHost directive, since those are used to funnel requests to name-based vhosts. Defaults to 'false'.

#####`itk`

Configures [ITK](http://mpm-itk.sesse.net/) in a hash. Keys can be:

* user + group
* `assignuseridexpr`
* `assigngroupidexpr`
* `maxclientvhost`
* `nice`
* `limituidrange` (Linux 3.5.0 or newer)
* `limitgidrange` (Linux 3.5.0 or newer)

Usage typically looks like:

```puppet
    apache::vhost { 'sample.example.net':
      docroot => '/path/to/directory',
      itk     => {
        user  => 'someuser',
        group => 'somegroup',
      },
    }
```

#####`logroot`

Specifies the location of the virtual host's logfiles. Defaults to '/var/log/<apache log location>/'.

#####`$logroot_ensure`

Determines whether or not to remove the logroot directory for a virtual host. Valid values are 'directory', or 'absent'.

#####`logroot_mode`

Overrides the mode the logroot directory is set to. Defaults to undef. Do NOT give people write access to the directory the logs are stored
in without being aware of the consequences; see http://httpd.apache.org/docs/2.4/logs.html#security for details.

#####`log_level`

Specifies the verbosity of the error log. Defaults to 'warn' for the global server configuration and can be overridden on a per-vhost basis. Valid values are 'emerg', 'alert', 'crit', 'error', 'warn', 'notice', 'info' or 'debug'.

######`modsec_body_limit`

Configures the maximum request body size (in bytes) ModSecurity will accept for buffering

######`modsec_disable_vhost`

Boolean.  Only valid if apache::mod::security is included.  Used to disable mod_security on an individual vhost.  Only relevant if apache::mod::security is included.

######`modsec_disable_ids`

Array of mod_security IDs to remove from the vhost.  Also takes a hash allowing removal of an ID from a specific location.

```puppet
    apache::vhost { 'sample.example.net':
      modsec_disable_ids => [ 90015, 90016 ],
    }
```

```puppet
    apache::vhost { 'sample.example.net':
      modsec_disable_ids => { '/location1' => [ 90015, 90016 ] },
    }
```

######`modsec_disable_ips`

Array of IPs to exclude from mod_security rule matching

#####`no_proxy_uris`

Specifies URLs you do not want to proxy. This parameter is meant to be used in combination with [`proxy_dest`](#proxy_dest).

#####`no_proxy_uris_match`

This directive is equivalent to `no_proxy_uris`, but takes regular expressions.

#####`proxy_preserve_host`

Sets the [ProxyPreserveHost Directive](http://httpd.apache.org/docs/2.2/mod/mod_proxy.html#proxypreservehost).  true Enables the Host: line from an incoming request to be proxied to the host instead of hostname .  false sets this option to off (default).

#####`proxy_error_override`

Sets the [ProxyErrorOverride Directive](http://httpd.apache.org/docs/2.2/mod/mod_proxy.html#proxyerroroverride). This directive controls whether apache should override error pages for proxied content. This option is off by default.

#####`options`

Sets the [Options](http://httpd.apache.org/docs/current/mod/core.html#options) for the specified virtual host. Defaults to '['Indexes','FollowSymLinks','MultiViews']', as demonstrated below:

```puppet
    apache::vhost { 'site.name.fdqn':
      …
      options => ['Indexes','FollowSymLinks','MultiViews'],
    }
```

*Note:* If you use [`directories`](#parameter-directories-for-apachevhost), 'Options', 'Override', and 'DirectoryIndex' are ignored because they are parameters within `directories`.

#####`override`

Sets the overrides for the specified virtual host. Accepts an array of [AllowOverride](http://httpd.apache.org/docs/current/mod/core.html#allowoverride) arguments. Defaults to '[none]'.

#####`passenger_app_root`

Sets [PassengerRoot](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html#PassengerAppRoot), the location of the Passenger application root if different from the DocumentRoot.

#####`passenger_app_env`

Sets [PassengerAppEnv](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html#PassengerAppEnv), the environment for the Passenger application. If not specifies, defaults to the global setting or 'production'.

#####`passenger_ruby`

Sets [PassengerRuby](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html#PassengerRuby) on this virtual host, the Ruby interpreter to use for the application.

#####`passenger_min_instances`

Sets [PassengerMinInstances](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html#PassengerMinInstances), the minimum number of application processes to run.

#####`passenger_start_timeout`

Sets [PassengerStartTimeout](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html#_passengerstarttimeout_lt_seconds_gt), the timeout for the application startup.

#####`passenger_pre_start`

Sets [PassengerPreStart](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html#PassengerPreStart), the URL of the application if pre-starting is required.

#####`php_flags & values`

Allows per-vhost setting [`php_value`s or `php_flag`s](http://php.net/manual/en/configuration.changes.php). These flags or values can be overwritten by a user or an application. Defaults to '[]'.

#####`php_admin_flags & values`

Allows per-vhost setting [`php_admin_value`s or `php_admin_flag`s](http://php.net/manual/en/configuration.changes.php). These flags or values cannot be overwritten by a user or an application. Defaults to '[]'.

#####`port`

Sets the port the host is configured on. The module's defaults ensure the host listens on port 80 for non-SSL vhosts and port 443 for SSL vhosts. The host only listens on the port set in this parameter.

#####`priority`

Sets the relative load-order for Apache HTTPD VirtualHost configuration files. Defaults to '25'.

If nothing matches the priority, the first name-based vhost is used. Likewise, passing a higher priority causes the alphabetically first name-based vhost to be used if no other names match.

*Note:* You should not need to use this parameter. However, if you do use it, be aware that the `default_vhost` parameter for `apache::vhost` passes a priority of '15'.

Pass priority `false` to omit the priority prefix in file names.

#####`proxy_dest`

Specifies the destination address of a [ProxyPass](http://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypass) configuration. Defaults to 'undef'.

#####`proxy_pass`

Specifies an array of `path => URI` for a [ProxyPass](http://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypass) configuration. Defaults to 'undef'. Optionally parameters can be added as an array.

```puppet
apache::vhost { 'site.name.fdqn':
  …
  proxy_pass => [
    { 'path' => '/a', 'url' => 'http://backend-a/' },
    { 'path' => '/b', 'url' => 'http://backend-b/' },
    { 'path' => '/c', 'url' => 'http://backend-a/c', 'params' => {'max'=>20, 'ttl'=>120, 'retry'=>300}},
    { 'path' => '/l', 'url' => 'http://backend-xy',
      'reverse_urls' => ['http://backend-x', 'http://backend-y'] },
    { 'path' => '/d', 'url' => 'http://backend-a/d',
      'params' => { 'retry' => '0', 'timeout' => '5' }, },
    { 'path' => '/e', 'url' => 'http://backend-a/e',
      'keywords' => ['nocanon', 'interpolate'] },
    { 'path' => '/f', 'url' => 'http://backend-f/',
      'setenv' => ['proxy-nokeepalive 1','force-proxy-request-1.0 1']},
  ],
}
```

`reverse_urls` is optional and can be an array or a string. It is useful when used with `mod_proxy_balancer`.
`params` is an optional parameter. It allows to provide the ProxyPass key=value parameters (Connection settings).
`setenv` is optional and is an array to set environment variables for the proxy directive, for details see http://httpd.apache.org/docs/current/mod/mod_proxy.html#envsettings

#####`proxy_dest_match`

This directive is equivalent to proxy_dest, but takes regular expressions, see [ProxyPassMatch](http://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypassmatch) for details.

#####`proxy_dest_reverse_match`

Allows you to pass a ProxyPassReverse if `proxy_dest_match` is specified. See [ProxyPassReverse](http://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypassreverse) for details.

#####`proxy_pass_match`

This directive is equivalent to proxy_pass, but takes regular expressions, see [ProxyPassMatch](http://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypassmatch) for details.

#####`rack_base_uris`

Specifies the resource identifiers for a rack configuration. The file paths specified are listed as rack application roots for [Phusion Passenger](http://www.modrails.com/documentation/Users%20guide%20Apache.html#_railsbaseuri_and_rackbaseuri) in the _rack.erb template. Defaults to 'undef'.

#####`redirect_dest`

Specifies the address to redirect to. Defaults to 'undef'.

#####`redirect_source`

Specifies the source URIs that redirect to the destination specified in `redirect_dest`. If more than one item for redirect is supplied, the source and destination must be the same length, and the items are order-dependent.

```puppet
    apache::vhost { 'site.name.fdqn':
      …
      redirect_source => ['/images','/downloads'],
      redirect_dest   => ['http://img.example.com/','http://downloads.example.com/'],
    }
```

#####`redirect_status`

Specifies the status to append to the redirect. Defaults to 'undef'.

```puppet
    apache::vhost { 'site.name.fdqn':
      …
      redirect_status => ['temp','permanent'],
    }
```

#####`redirectmatch_regexp` & `redirectmatch_status` & `redirectmatch_dest`

Determines which server status should be raised for a given regular expression and where to forward the user to. Entered as arrays. Defaults to 'undef'.

```puppet
    apache::vhost { 'site.name.fdqn':
      …
      redirectmatch_status => ['404','404'],
      redirectmatch_regexp => ['\.git(/.*|$)/','\.svn(/.*|$)'],
      redirectmatch_dest => ['http://www.example.com/1','http://www.example.com/2'],
    }
```

#####`request_headers`

Modifies collected [request headers](http://httpd.apache.org/docs/current/mod/mod_headers.html#requestheader) in various ways, including adding additional request headers, removing request headers, etc. Defaults to 'undef'.

```puppet
    apache::vhost { 'site.name.fdqn':
      …
      request_headers => [
        'append MirrorID "mirror 12"',
        'unset MirrorID',
      ],
    }
```

#####`rewrites`

Creates URL rewrite rules. Expects an array of hashes, and the hash keys can be any of 'comment', 'rewrite_base', 'rewrite_cond', 'rewrite_rule' or 'rewrite_map'. Defaults to 'undef'.

For example, you can specify that anyone trying to access index.html is served welcome.html

```puppet
    apache::vhost { 'site.name.fdqn':
      …
      rewrites => [ { rewrite_rule => ['^index\.html$ welcome.html'] } ]
    }
```

The parameter allows rewrite conditions that, when true, execute the associated rule. For instance, if you wanted to rewrite URLs only if the visitor is using IE

```puppet
    apache::vhost { 'site.name.fdqn':
      …
      rewrites => [
        {
          comment      => 'redirect IE',
          rewrite_cond => ['%{HTTP_USER_AGENT} ^MSIE'],
          rewrite_rule => ['^index\.html$ welcome.html'],
        },
      ],
    }
```

You can also apply multiple conditions. For instance, rewrite index.html to welcome.html only when the browser is Lynx or Mozilla (version 1 or 2)

```puppet
    apache::vhost { 'site.name.fdqn':
      …
      rewrites => [
        {
          comment      => 'Lynx or Mozilla v1/2',
          rewrite_cond => ['%{HTTP_USER_AGENT} ^Lynx/ [OR]', '%{HTTP_USER_AGENT} ^Mozilla/[12]'],
          rewrite_rule => ['^index\.html$ welcome.html'],
        },
      ],
    }
```

Multiple rewrites and conditions are also possible

```puppet
    apache::vhost { 'site.name.fdqn':
      …
      rewrites => [
        {
          comment      => 'Lynx or Mozilla v1/2',
          rewrite_cond => ['%{HTTP_USER_AGENT} ^Lynx/ [OR]', '%{HTTP_USER_AGENT} ^Mozilla/[12]'],
          rewrite_rule => ['^index\.html$ welcome.html'],
        },
        {
          comment      => 'Internet Explorer',
          rewrite_cond => ['%{HTTP_USER_AGENT} ^MSIE'],
          rewrite_rule => ['^index\.html$ /index.IE.html [L]'],
        },
        {
          rewrite_base => /apps/,
          rewrite_rule => ['^index\.cgi$ index.php', '^index\.html$ index.php', '^index\.asp$ index.html'],
        },
        { comment      => 'Rewrite to lower case',
          rewrite_cond => ['%{REQUEST_URI} [A-Z]'],
          rewrite_map  => ['lc int:tolower'],
          rewrite_rule => ['(.*) ${lc:$1} [R=301,L]'],
        },
     ],
    }
```

Refer to the [`mod_rewrite` documentation](http://httpd.apache.org/docs/current/mod/mod_rewrite.html) for more details on what is possible with rewrite rules and conditions.

#####`scriptalias`

Defines a directory of CGI scripts to be aliased to the path '/cgi-bin', for example: '/usr/scripts'. Defaults to 'undef'.

#####`scriptaliases`

*Note*: This parameter is deprecated in favour of the `aliases` parameter.

Passes an array of hashes to the vhost to create either ScriptAlias or ScriptAliasMatch statements as per the [`mod_alias` documentation](http://httpd.apache.org/docs/current/mod/mod_alias.html). These hashes are formatted as follows:

```puppet
    scriptaliases => [
      {
        alias => '/myscript',
        path  => '/usr/share/myscript',
      },
      {
        aliasmatch => '^/foo(.*)',
        path       => '/usr/share/fooscripts$1',
      },
      {
        aliasmatch => '^/bar/(.*)',
        path       => '/usr/share/bar/wrapper.sh/$1',
      },
      {
        alias => '/neatscript',
        path  => '/usr/share/neatscript',
      },
    ]
```

The ScriptAlias and ScriptAliasMatch directives are created in the order specified. As with [Alias and AliasMatch](#aliases) directives, more specific aliases should come before more general ones to avoid shadowing.

#####`serveradmin`

Specifies the email address Apache displays when it renders one of its error pages. Defaults to 'undef'.

#####`serveraliases`

Sets the [ServerAliases](http://httpd.apache.org/docs/current/mod/core.html#serveralias) of the site. Defaults to '[]'.

#####`servername`

Sets the servername corresponding to the hostname you connect to the virtual host at. Defaults to the title of the resource.

#####`setenv`

Used by HTTPD to set environment variables for vhosts. Defaults to '[]'.

Example:

```puppet
    apache::vhost { 'setenv.example.com':
      setenv => ['SPECIAL_PATH /foo/bin'],
    }
```

#####`setenvif`

Used by HTTPD to conditionally set environment variables for vhosts. Defaults to '[]'.

#####`suphp_addhandler`, `suphp_configpath`, & `suphp_engine`

Set up a virtual host with [suPHP](http://suphp.org/DocumentationView.html?file=apache/CONFIG).

`suphp_addhandler` defaults to 'php5-script' on RedHat and FreeBSD, and 'x-httpd-php' on Debian and Gentoo.

`suphp_configpath` defaults to 'undef' on RedHat and FreeBSD, and '/etc/php5/apache2' on Debian and Gentoo.

`suphp_engine` allows values 'on' or 'off'. Defaults to 'off'

To set up a virtual host with suPHP

```puppet
    apache::vhost { 'suphp.example.com':
      port                => '80',
      docroot             => '/home/appuser/myphpapp',
      suphp_addhandler    => 'x-httpd-php',
      suphp_engine        => 'on',
      suphp_configpath    => '/etc/php5/apache2',
      directories         => { path => '/home/appuser/myphpapp',
        'suphp'           => { user => 'myappuser', group => 'myappgroup' },
      }
    }
```

#####`vhost_name`

Enables name-based virtual hosting. If no IP is passed to the virtual host, but the vhost is assigned a port, then the vhost name is 'vhost_name:port'. If the virtual host has no assigned IP or port, the vhost name is set to the title of the resource. Defaults to '*'.

#####`virtual_docroot`

Sets up a virtual host with a wildcard alias subdomain mapped to a directory with the same name. For example, 'http://example.com' would map to '/var/www/example.com'. Defaults to 'false'.

```puppet
    apache::vhost { 'subdomain.loc':
      vhost_name       => '*',
      port             => '80',
      virtual_docroot' => '/var/www/%-2+',
      docroot          => '/var/www',
      serveraliases    => ['*.loc',],
    }
```

#####`wsgi_daemon_process`, `wsgi_daemon_process_options`, `wsgi_process_group`, `wsgi_script_aliases`, & `wsgi_pass_authorization`

Set up a virtual host with [WSGI](https://code.google.com/p/modwsgi/).

`wsgi_daemon_process` sets the name of the WSGI daemon. It is a hash, accepting [these keys](http://modwsgi.readthedocs.org/en/latest/configuration-directives/WSGIDaemonProcess.html), and it defaults to 'undef'.

`wsgi_daemon_process_options` is optional and defaults to 'undef'.

`wsgi_process_group` sets the group ID the virtual host runs under. Defaults to 'undef'.

`wsgi_script_aliases` requires a hash of web paths to filesystem .wsgi paths. Defaults to 'undef'.

`wsgi_pass_authorization` the WSGI application handles authorisation instead of Apache when set to 'On'. For more information see [here] (http://modwsgi.readthedocs.org/en/latest/configuration-directives/WSGIPassAuthorization.html).  Defaults to 'undef' where apache sets the defaults setting to 'Off'.

`wsgi_chunked_request` enables support for chunked requests. Defaults to 'undef'.

To set up a virtual host with WSGI

```puppet
    apache::vhost { 'wsgi.example.com':
      port                        => '80',
      docroot                     => '/var/www/pythonapp',
      wsgi_daemon_process         => 'wsgi',
      wsgi_daemon_process_options =>
        { processes    => '2',
          threads      => '15',
          display-name => '%{GROUP}',
         },
      wsgi_process_group          => 'wsgi',
      wsgi_script_aliases         => { '/' => '/var/www/demo.wsgi' },
      wsgi_chunked_request        => 'On',
    }
```

####Parameter `directories` for `apache::vhost`

The `directories` parameter within the `apache::vhost` class passes an array of hashes to the vhost to create [Directory](http://httpd.apache.org/docs/current/mod/core.html#directory), [File](http://httpd.apache.org/docs/current/mod/core.html#files), and [Location](http://httpd.apache.org/docs/current/mod/core.html#location) directive blocks. These blocks take the form, '< Directory /path/to/directory>...< /Directory>'.

The `path` key sets the path for the directory, files, and location blocks. Its value must be a path for the 'directory', 'files', and 'location' providers, or a regex for the 'directorymatch', 'filesmatch', or 'locationmatch' providers. Each hash passed to `directories` **must** contain `path` as one of the keys.

The `provider` key is optional. If missing, this key defaults to 'directory'. Valid values for `provider` are 'directory', 'files', 'location', 'directorymatch', 'filesmatch', or 'locationmatch'. If you set `provider` to 'directorymatch', it uses the keyword 'DirectoryMatch' in the Apache config file.

General `directories` usage looks something like

```puppet
    apache::vhost { 'files.example.net':
      docroot     => '/var/www/files',
      directories => [
        { 'path'     => '/var/www/files',
          'provider' => 'files',
          'deny'     => 'from all'
         },
      ],
    }
```

*Note:* At least one directory should match the `docroot` parameter. After you start declaring directories, `apache::vhost` assumes that all required Directory blocks will be declared. If not defined, a single default Directory block is created that matches the `docroot` parameter.

Available handlers, represented as keys, should be placed within the `directory`,`'files`, or `location` hashes.  This looks like

```puppet
    apache::vhost { 'sample.example.net':
      docroot     => '/path/to/directory',
      directories => [ { path => '/path/to/directory', handler => value } ],
}
```

Any handlers you do not set in these hashes are considered 'undefined' within Puppet and are not added to the virtual host, resulting in the module using their default values. Supported handlers are:

######`addhandlers`

Sets [AddHandler](http://httpd.apache.org/docs/current/mod/mod_mime.html#addhandler) directives, which map filename extensions to the specified handler. Accepts a list of hashes, with `extensions` serving to list the extensions being managed by the handler, and takes the form: `{ handler => 'handler-name', extensions => ['extension']}`.

```puppet
    apache::vhost { 'sample.example.net':
      docroot     => '/path/to/directory',
      directories => [
        { path        => '/path/to/directory',
          addhandlers => [{ handler => 'cgi-script', extensions => ['.cgi']}],
        },
      ],
    }
```

######`allow`

Sets an [Allow](http://httpd.apache.org/docs/2.2/mod/mod_authz_host.html#allow) directive, which groups authorizations based on hostnames or IPs. **Deprecated:** This parameter is being deprecated due to a change in Apache. It only works with Apache 2.2 and lower. You can use it as a single string for one rule or as an array for more than one.

```puppet
    apache::vhost { 'sample.example.net':
      docroot     => '/path/to/directory',
      directories => [
        { path  => '/path/to/directory',
          allow => 'from example.org',
        },
      ],
    }
```

######`allow_override`

Sets the types of directives allowed in [.htaccess](http://httpd.apache.org/docs/current/mod/core.html#allowoverride) files. Accepts an array.

```puppet
    apache::vhost { 'sample.example.net':
      docroot      => '/path/to/directory',
      directories  => [
        { path           => '/path/to/directory',
          allow_override => ['AuthConfig', 'Indexes'],
        },
      ],
    }
```

######`auth_basic_authoritative`

Sets the value for [AuthBasicAuthoritative](https://httpd.apache.org/docs/current/mod/mod_auth_basic.html#authbasicauthoritative), which determines whether authorization and authentication are passed to lower level Apache modules.

######`auth_basic_fake`

Sets the value for [AuthBasicFake](http://httpd.apache.org/docs/current/mod/mod_auth_basic.html#authbasicfake), which statically configures authorization credentials for a given directive block.

######`auth_basic_provider`

Sets the value for [AuthBasicProvider] (http://httpd.apache.org/docs/current/mod/mod_auth_basic.html#authbasicprovider), which sets the authentication provider for a given location.

######`auth_digest_algorithm`

Sets the value for [AuthDigestAlgorithm](http://httpd.apache.org/docs/current/mod/mod_auth_digest.html#authdigestalgorithm), which selects the algorithm used to calculate the challenge and response hashes.

######`auth_digest_domain`

Sets the value for [AuthDigestDomain](http://httpd.apache.org/docs/current/mod/mod_auth_digest.html#authdigestdomain), which allows you to specify one or more URIs in the same protection space for digest authentication.

######`auth_digest_nonce_lifetime`

Sets the value for [AuthDigestNonceLifetime](http://httpd.apache.org/docs/current/mod/mod_auth_digest.html#authdigestnoncelifetime), which controls how long the server nonce is valid.

######`auth_digest_provider`

Sets the value for [AuthDigestProvider](http://httpd.apache.org/docs/current/mod/mod_auth_digest.html#authdigestprovider), which sets the authentication provider for a given location.

######`auth_digest_qop`

Sets the value for [AuthDigestQop](http://httpd.apache.org/docs/current/mod/mod_auth_digest.html#authdigestqop), which determines the quality-of-protection to use in digest authentication.

######`auth_digest_shmem_size`

Sets the value for [AuthAuthDigestShmemSize](http://httpd.apache.org/docs/current/mod/mod_auth_digest.html#authdigestshmemsize), which defines the amount of shared memory allocated to the server for keeping track of clients.

######`auth_group_file`

Sets the value for [AuthGroupFile](https://httpd.apache.org/docs/current/mod/mod_authz_groupfile.html#authgroupfile), which sets the name of the text file containing the list of user groups for authorization.

######`auth_name`

Sets the value for [AuthName](http://httpd.apache.org/docs/current/mod/mod_authn_core.html#authname), which sets the name of the authorization realm.

######`auth_require`

Sets the entity name you're requiring to allow access. Read more about [Require](http://httpd.apache.org/docs/current/mod/mod_authz_host.html#requiredirectives).

######`auth_type`

Sets the value for [AuthType](http://httpd.apache.org/docs/current/mod/mod_authn_core.html#authtype), which guides the type of user authentication.

######`auth_user_file`

Sets the value for [AuthUserFile](http://httpd.apache.org/docs/current/mod/mod_authn_file.html#authuserfile), which sets the name of the text file containing the users/passwords for authentication.

######`custom_fragment`

Pass a string of custom configuration directives to be placed at the end of the directory configuration.

```puppet
  apache::vhost { 'monitor':
    …
    directories => [
      {
        path => '/path/to/directory',
        custom_fragment => '
  <Location /balancer-manager>
    SetHandler balancer-manager
    Order allow,deny
    Allow from all
  </Location>
  <Location /server-status>
    SetHandler server-status
    Order allow,deny
    Allow from all
  </Location>
  ProxyStatus On',
      },
    ]
  }
```

######`deny`

Sets a [Deny](http://httpd.apache.org/docs/2.2/mod/mod_authz_host.html#deny) directive, specifying which hosts are denied access to the server. **Deprecated:** This parameter is being deprecated due to a change in Apache. It only works with Apache 2.2 and lower. You can use it as a single string for one rule or as an array for more than one.

```puppet
    apache::vhost { 'sample.example.net':
      docroot     => '/path/to/directory',
      directories => [
        { path => '/path/to/directory',
          deny => 'from example.org',
        },
      ],
    }
```

######`error_documents`

An array of hashes used to override the [ErrorDocument](https://httpd.apache.org/docs/current/mod/core.html#errordocument) settings for the directory.

```puppet
    apache::vhost { 'sample.example.net':
      directories => [
        { path            => '/srv/www',
          error_documents => [
            { 'error_code' => '503',
              'document'   => '/service-unavail',
            },
          ],
        },
      ],
    }
```

######`headers`

Adds lines for [Header](http://httpd.apache.org/docs/current/mod/mod_headers.html#header) directives.

```puppet
    apache::vhost { 'sample.example.net':
      docroot     => '/path/to/directory',
      directories => {
        path    => '/path/to/directory',
        headers => 'Set X-Robots-Tag "noindex, noarchive, nosnippet"',
      },
    }
```

######`index_options`

Allows configuration settings for [directory indexing](http://httpd.apache.org/docs/current/mod/mod_autoindex.html#indexoptions).

```puppet
    apache::vhost { 'sample.example.net':
      docroot     => '/path/to/directory',
      directories => [
        { path          => '/path/to/directory',
          options       => ['Indexes','FollowSymLinks','MultiViews'],
          index_options => ['IgnoreCase', 'FancyIndexing', 'FoldersFirst', 'NameWidth=*', 'DescriptionWidth=*', 'SuppressHTMLPreamble'],
        },
      ],
    }
```

######`index_order_default`

Sets the [default ordering](http://httpd.apache.org/docs/current/mod/mod_autoindex.html#indexorderdefault) of the directory index.

```puppet
    apache::vhost { 'sample.example.net':
      docroot     => '/path/to/directory',
      directories => [
        { path                => '/path/to/directory',
          order               => 'Allow,Deny',
          index_order_default => ['Descending', 'Date'],
        },
      ],
    }
```

######`options`

Lists the [Options](http://httpd.apache.org/docs/current/mod/core.html#options) for the given Directory block.

```puppet
    apache::vhost { 'sample.example.net':
      docroot     => '/path/to/directory',
      directories => [
        { path    => '/path/to/directory',
          options => ['Indexes','FollowSymLinks','MultiViews'],
        },
      ],
    }
```

######`order`

Sets the order of processing Allow and Deny statements as per [Apache core documentation](http://httpd.apache.org/docs/2.2/mod/mod_authz_host.html#order). **Deprecated:** This parameter is being deprecated due to a change in Apache. It only works with Apache 2.2 and lower.

```puppet
    apache::vhost { 'sample.example.net':
      docroot     => '/path/to/directory',
      directories => [
        { path  => '/path/to/directory',
          order => 'Allow,Deny',
        },
      ],
    }
```

######`passenger_enabled`

Sets the value for the [PassengerEnabled](http://www.modrails.com/documentation/Users%20guide%20Apache.html#PassengerEnabled) directory to 'on' or 'off'. Requires `apache::mod::passenger` to be included.

```puppet
    apache::vhost { 'sample.example.net':
      docroot     => '/path/to/directory',
      directories => [
        { path              => '/path/to/directory',
          passenger_enabled => 'on',
        },
      ],
    }
```

*Note:* Be aware that there is an [issue](http://www.conandalton.net/2010/06/passengerenabled-off-not-working.html) using the PassengerEnabled directive with the PassengerHighPerformance directive.

######`php_value` and `php_flag`

`php_value` sets the value of the directory, and `php_flag` uses a boolean to configure the directory. Further information can be found [here](http://php.net/manual/en/configuration.changes.php).

######`php_admin_value` and `php_admin_flag`

`php_admin_value` sets the value of the directory, and `php_admin_flag` uses a boolean to configure the directory. Further information can be found [here](http://php.net/manual/en/configuration.changes.php).


######`satisfy`

Sets a `Satisfy` directive as per the [Apache Core documentation](http://httpd.apache.org/docs/2.2/mod/core.html#satisfy). **Deprecated:** This parameter is being deprecated due to a change in Apache. It only works with Apache 2.2 and lower.

```puppet
    apache::vhost { 'sample.example.net':
      docroot     => '/path/to/directory',
      directories => [
        { path    => '/path/to/directory',
          satisfy => 'Any',
        }
      ],
    }
```

######`sethandler`

Sets a `SetHandler` directive as per the [Apache Core documentation](http://httpd.apache.org/docs/2.2/mod/core.html#sethandler). An example:

```puppet
    apache::vhost { 'sample.example.net':
      docroot     => '/path/to/directory',
      directories => [
        { path       => '/path/to/directory',
          sethandler => 'None',
        }
      ],
    }
```

######`rewrites`

Creates URL [`rewrites`](#rewrites) rules in vhost directories. Expects an array of hashes, and the hash keys can be any of 'comment', 'rewrite_base', 'rewrite_cond', or 'rewrite_rule'.

```puppet
    apache::vhost { 'secure.example.net':
      docroot     => '/path/to/directory',
      directories => [
        { path        => '/path/to/directory',
          rewrites => [ { comment      => 'Permalink Rewrites',
                          rewrite_base => '/'
                        },
                        { rewrite_rule => [ '^index\.php$ - [L]' ]
                        },
                        { rewrite_cond => [ '%{REQUEST_FILENAME} !-f',
                                            '%{REQUEST_FILENAME} !-d',
                                          ],
                          rewrite_rule => [ '. /index.php [L]' ],
                        }
                      ],
        },
      ],
    }
```

***Note*** If you include rewrites in your directories make sure you are also including `apache::mod::rewrite`. You may also want to consider setting the rewrites using the `rewrites` parameter in `apache::vhost` rather than setting the rewrites in the vhost directories.

######`shib_request_setting`

Allows an valid content setting to be set or altered for the application request. This command takes two parameters, the name of the content setting, and the value to set it to.Check the Shibboleth [content setting documentation](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPContentSettings) for valid settings. This key is disabled if `apache::mod::shib` is not defined. Check the [`mod_shib` documentation](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPApacheConfig#NativeSPApacheConfig-Server/VirtualHostOptions) for more details.

```puppet
    apache::vhost { 'secure.example.net':
      docroot     => '/path/to/directory',
      directories => [
        { path                  => '/path/to/directory',
          shib_require_setting  => 'requiresession 1',
          shib_use_headers      => 'On',
        },
      ],
    }
```

######`shib_use_headers`

When set to 'On' this turns on the use of request headers to publish attributes to applications. Valid values for this key is 'On' or 'Off', and the default value is 'Off'. This key is disabled if `apache::mod::shib` is not defined. Check the [`mod_shib` documentation](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPApacheConfig#NativeSPApacheConfig-Server/VirtualHostOptions) for more details.

######`ssl_options`

String or list of [SSLOptions](https://httpd.apache.org/docs/current/mod/mod_ssl.html#ssloptions), which configure SSL engine run-time options. This handler takes precedence over SSLOptions set in the parent block of the vhost.

```puppet
    apache::vhost { 'secure.example.net':
      docroot     => '/path/to/directory',
      directories => [
        { path        => '/path/to/directory',
          ssl_options => '+ExportCertData',
        },
        { path        => '/path/to/different/dir',
          ssl_options => [ '-StdEnvVars', '+ExportCertData'],
        },
      ],
    }
```

######`suphp`

A hash containing the 'user' and 'group' keys for the [suPHP_UserGroup](http://www.suphp.org/DocumentationView.html?file=apache/CONFIG) setting. It must be used with `suphp_engine => on` in the vhost declaration, and can only be passed within `directories`.

```puppet
    apache::vhost { 'secure.example.net':
      docroot     => '/path/to/directory',
      directories => [
        { path  => '/path/to/directory',
          suphp =>
            { user  =>  'myappuser',
              group => 'myappgroup',
            },
        },
      ],
    }
```

####SSL parameters for `apache::vhost`

All of the SSL parameters for `::vhost` default to whatever is set in the base `apache` class. Use the below parameters to tweak individual SSL settings for specific vhosts.

#####`ssl`

Enables SSL for the virtual host. SSL vhosts only respond to HTTPS queries. Valid values are 'true' or 'false'. Defaults to 'false'.

#####`ssl_ca`

Specifies the SSL certificate authority. Defaults to 'undef'.

#####`ssl_cert`

Specifies the SSL certification. Defaults are based on your OS: '/etc/pki/tls/certs/localhost.crt' for RedHat, '/etc/ssl/certs/ssl-cert-snakeoil.pem' for Debian, '/usr/local/etc/apache22/server.crt' for FreeBSD, and '/etc/ssl/apache2/server.crt' on Gentoo.

#####`ssl_protocol`

Specifies [SSLProtocol](http://httpd.apache.org/docs/current/mod/mod_ssl.html#sslprotocol). Expects an array of accepted protocols. Defaults to 'all', '-SSLv2', '-SSLv3'.

#####`ssl_cipher`

Specifies [SSLCipherSuite](http://httpd.apache.org/docs/current/mod/mod_ssl.html#sslciphersuite). Defaults to 'HIGH:MEDIUM:!aNULL:!MD5'.

#####`ssl_honorcipherorder`

Sets [SSLHonorCipherOrder](http://httpd.apache.org/docs/current/mod/mod_ssl.html#sslhonorcipherorder), which is used to prefer the server's cipher preference order. Defaults to 'On' in the base `apache` config.

#####`ssl_certs_dir`

Specifies the location of the SSL certification directory. Defaults to '/etc/ssl/certs' on Debian, '/etc/pki/tls/certs' on RedHat, '/usr/local/etc/apache22' on FreeBSD, and '/etc/ssl/apache2' on Gentoo.

#####`ssl_chain`

Specifies the SSL chain. Defaults to 'undef'. (This default works out of the box, but it must be updated in the base `apache` class with your specific certificate information before being used in production.)

#####`ssl_crl`

Specifies the certificate revocation list to use. Defaults to 'undef'. (This default works out of the box but must be updated in the base `apache` class with your specific certificate information before being used in production.)

#####`ssl_crl_path`

Specifies the location of the certificate revocation list. Defaults to 'undef'. (This default works out of the box but must be updated in the base `apache` class with your specific certificate information before being used in production.)

#####`ssl_crl_check`

Sets the certificate revocation check level via the [SSLCARevocationCheck directive](http://httpd.apache.org/docs/current/mod/mod_ssl.html#sslcarevocationcheck), defaults to 'undef'. This default works out of the box but must be specified when using CRLs in production. Only applicable to Apache 2.4 or higher; the value is ignored on older versions.

#####`ssl_key`

Specifies the SSL key. Defaults are based on your operating system: '/etc/pki/tls/private/localhost.key' for RedHat, '/etc/ssl/private/ssl-cert-snakeoil.key' for Debian, '/usr/local/etc/apache22/server.key' for FreeBSD, and '/etc/ssl/apache2/server.key' on Gentoo. (This default works out of the box but must be updated in the base `apache` class with your specific certificate information before being used in production.)

#####`ssl_verify_client`

Sets the [SSLVerifyClient](http://httpd.apache.org/docs/current/mod/mod_ssl.html#sslverifyclient) directive, which sets the certificate verification level for client authentication. Valid values are: 'none', 'optional', 'require', and 'optional_no_ca'. Defaults to 'undef'.

```puppet
    apache::vhost { 'sample.example.net':
      …
      ssl_verify_client => 'optional',
    }
```

#####`ssl_verify_depth`

Sets the [SSLVerifyDepth](http://httpd.apache.org/docs/current/mod/mod_ssl.html#sslverifydepth) directive, which specifies the maximum depth of CA certificates in client certificate verification. Defaults to 'undef'.

```puppet
    apache::vhost { 'sample.example.net':
      …
      ssl_verify_depth => 1,
    }
```

#####`ssl_options`

Sets the [SSLOptions](http://httpd.apache.org/docs/current/mod/mod_ssl.html#ssloptions) directive, which configures various SSL engine run-time options. This is the global setting for the given vhost and can be a string or an array. Defaults to 'undef'.

A string:

```puppet
    apache::vhost { 'sample.example.net':
      …
      ssl_options => '+ExportCertData',
    }
```

An array:

```puppet
    apache::vhost { 'sample.example.net':
      …
      ssl_options => [ '+StrictRequire', '+ExportCertData' ],
    }
```

#####`ssl_proxyengine`

Specifies whether or not to use [SSLProxyEngine](http://httpd.apache.org/docs/current/mod/mod_ssl.html#sslproxyengine). Valid values are 'true' and 'false'. Defaults to 'false'.

####Defined Type: FastCGI Server

This type is intended for use with mod_fastcgi. It allows you to define one or more external FastCGI servers to handle specific file types.

Ex:

```puppet
apache::fastcgi::server { 'php':
  host       => '127.0.0.1:9000',
  timeout    => 15,
  flush      => false,
  faux_path  => '/var/www/php.fcgi',
  fcgi_alias => '/php.fcgi',
  file_type  => 'application/x-httpd-php'
}
```

Within your virtual host, you can then configure the specified file type to be handled by the fastcgi server specified above.

```puppet
apache::vhost { 'www':
  ...
  custom_fragment => 'AddType application/x-httpd-php .php'
  ...
}
```

#####`host`

The hostname or IP address and TCP port number (1-65535) of the FastCGI server.

#####`timeout`

The number of seconds of FastCGI application inactivity allowed before the request is aborted and the event is logged (at the error LogLevel). The inactivity timer applies only as long as a connection is pending with the FastCGI application. If a request is queued to an application, but the application doesn't respond (by writing and flushing) within this period, the request is aborted. If communication is complete with the application but incomplete with the client (the response is buffered), the timeout does not apply.

#####`flush`

Force a write to the client as data is received from the application. By default, mod_fastcgi buffers data in order to free the application as quickly as possible.

#####`faux_path`

`faux_path` does not have to exist in the local filesystem. URIs that Apache resolves to this filename are handled by this external FastCGI application.

#####`alias`

A unique alias. This is used internally to link the action with the FastCGI server.

#####`file_type`

The MIME-type of the file to be processed by the FastCGI server.

###Virtual Host Examples

The apache module allows you to set up pretty much any configuration of virtual host you might need. This section addresses some common configurations, but look at the [Tests section](https://github.com/puppetlabs/puppetlabs-apache/tree/master/tests) for even more examples.

Configure a vhost with a server administrator

```puppet
    apache::vhost { 'third.example.com':
      port        => '80',
      docroot     => '/var/www/third',
      serveradmin => 'admin@example.com',
    }
```

- - -

Set up a vhost with aliased servers

```puppet
    apache::vhost { 'sixth.example.com':
      serveraliases => [
        'sixth.example.org',
        'sixth.example.net',
      ],
      port          => '80',
      docroot       => '/var/www/fifth',
    }
```

- - -

Configure a vhost with a cgi-bin

```puppet
    apache::vhost { 'eleventh.example.com':
      port        => '80',
      docroot     => '/var/www/eleventh',
      scriptalias => '/usr/lib/cgi-bin',
    }
```

- - -

Set up a vhost with a rack configuration

```puppet
    apache::vhost { 'fifteenth.example.com':
      port           => '80',
      docroot        => '/var/www/fifteenth',
      rack_base_uris => ['/rackapp1', '/rackapp2'],
    }
```

- - -

Set up a mix of SSL and non-SSL vhosts at the same domain

```puppet
    #The non-ssl vhost
    apache::vhost { 'first.example.com non-ssl':
      servername => 'first.example.com',
      port       => '80',
      docroot    => '/var/www/first',
    }

    #The SSL vhost at the same domain
    apache::vhost { 'first.example.com ssl':
      servername => 'first.example.com',
      port       => '443',
      docroot    => '/var/www/first',
      ssl        => true,
    }
```

- - -

Configure a vhost to redirect non-SSL connections to SSL

```puppet
    apache::vhost { 'sixteenth.example.com non-ssl':
      servername      => 'sixteenth.example.com',
      port            => '80',
      docroot         => '/var/www/sixteenth',
      redirect_status => 'permanent',
      redirect_dest   => 'https://sixteenth.example.com/'
    }
    apache::vhost { 'sixteenth.example.com ssl':
      servername => 'sixteenth.example.com',
      port       => '443',
      docroot    => '/var/www/sixteenth',
      ssl        => true,
    }
```

- - -

Set up IP-based vhosts on any listen port and have them respond to requests on specific IP addresses. In this example, we set listening on ports 80 and 81. This is required because the example vhosts are not declared with a port parameter.

```puppet
    apache::listen { '80': }
    apache::listen { '81': }
```

Then we set up the IP-based vhosts

```puppet
    apache::vhost { 'first.example.com':
      ip       => '10.0.0.10',
      docroot  => '/var/www/first',
      ip_based => true,
    }
    apache::vhost { 'second.example.com':
      ip       => '10.0.0.11',
      docroot  => '/var/www/second',
      ip_based => true,
    }
```

- - -

Configure a mix of name-based and IP-based vhosts. First, we add two IP-based vhosts on 10.0.0.10, one SSL and one non-SSL

```puppet
    apache::vhost { 'The first IP-based vhost, non-ssl':
      servername => 'first.example.com',
      ip         => '10.0.0.10',
      port       => '80',
      ip_based   => true,
      docroot    => '/var/www/first',
    }
    apache::vhost { 'The first IP-based vhost, ssl':
      servername => 'first.example.com',
      ip         => '10.0.0.10',
      port       => '443',
      ip_based   => true,
      docroot    => '/var/www/first-ssl',
      ssl        => true,
    }
```

Then, we add two name-based vhosts listening on 10.0.0.20

```puppet
    apache::vhost { 'second.example.com':
      ip      => '10.0.0.20',
      port    => '80',
      docroot => '/var/www/second',
    }
    apache::vhost { 'third.example.com':
      ip      => '10.0.0.20',
      port    => '80',
      docroot => '/var/www/third',
    }
```

If you want to add two name-based vhosts so that they answer on either 10.0.0.10 or 10.0.0.20, you **MUST** declare `add_listen => 'false'` to disable the otherwise automatic 'Listen 80', as it conflicts with the preceding IP-based vhosts.

```puppet
    apache::vhost { 'fourth.example.com':
      port       => '80',
      docroot    => '/var/www/fourth',
      add_listen => false,
    }
    apache::vhost { 'fifth.example.com':
      port       => '80',
      docroot    => '/var/www/fifth',
      add_listen => false,
    }
```

###Load Balancing

####Defined Type: `apache::balancer`

`apache::balancer` creates an Apache balancer cluster. Each balancer cluster needs one or more balancer members, which are declared with [`apache::balancermember`](#defined-type-apachebalancermember).

One `apache::balancer` defined resource should be defined for each Apache load balanced set of servers. The `apache::balancermember` resources for all balancer members can be exported and collected on a single Apache load balancer server using exported resources.

**Parameters within `apache::balancer`:**

#####`name`

Sets the balancer cluster's title. This parameter also sets the title of the conf.d file.

#####`proxy_set`

Configures key-value pairs as [ProxySet](http://httpd.apache.org/docs/current/mod/mod_proxy.html#proxyset) lines. Accepts a hash, and defaults to '{}'.

#####`collect_exported`

Determines whether or not to use exported resources. Valid values 'true' and 'false', defaults to 'true'.

If you statically declare all of your backend servers, you should set this to 'false' to rely on existing declared balancer member resources. Also make sure to use `apache::balancermember` with array arguments.

If you wish to dynamically declare your backend servers via [exported resources](http://docs.puppetlabs.com/guides/exported_resources.html) collected on a central node, you must set this parameter to 'true' in order to collect the exported balancer member resources that were exported by the balancer member nodes.

If you choose not to use exported resources, all balancer members will be configured in a single Puppet run. If you are using exported resources, Puppet has to run on the balanced nodes, then run on the balancer.

####Defined Type: `apache::balancermember`

Defines members of [mod_proxy_balancer](http://httpd.apache.org/docs/current/mod/mod_proxy_balancer.html), which sets up a balancer member inside a listening service configuration block in etc/apache/apache.cfg on the load balancer.

**Parameters within `apache::balancermember`:**

#####`name`

Sets the title of the resource. This name also sets the name of the concat fragment.

#####`balancer_cluster`

Sets the Apache service's instance name. This must match the name of a declared `apache::balancer` resource. Required.

#####`url`

Specifies the URL used to contact the balancer member server. Defaults to 'http://${::fqdn}/'.

#####`options`

An array of [options](http://httpd.apache.org/docs/2.2/mod/mod_proxy.html#balancermember) to be specified after the URL. Accepts any key-value pairs available to [ProxyPass](http://httpd.apache.org/docs/2.2/mod/mod_proxy.html#proxypass).

####Examples

To load balance with exported resources, export the `balancermember` from the balancer member

```puppet
      @@apache::balancermember { "${::fqdn}-puppet00":
        balancer_cluster => 'puppet00',
        url              => "ajp://${::fqdn}:8009"
        options          => ['ping=5', 'disablereuse=on', 'retry=5', 'ttl=120'],
      }
```

Then, on the proxy server, create the balancer cluster

```puppet
      apache::balancer { 'puppet00': }
```

To load balance without exported resources, declare the following on the proxy

```puppet
    apache::balancer { 'puppet00': }
    apache::balancermember { "${::fqdn}-puppet00":
        balancer_cluster => 'puppet00',
        url              => "ajp://${::fqdn}:8009"
        options          => ['ping=5', 'disablereuse=on', 'retry=5', 'ttl=120'],
      }
```

Then declare `apache::balancer` and `apache::balancermember` on the proxy server.

If you need to use ProxySet in the balancer config

```puppet
      apache::balancer { 'puppet01':
        proxy_set => {'stickysession' => 'JSESSIONID'},
      }
```

##Reference

###Classes

####Public Classes

* [`apache`](#class-apache): Guides the basic setup of Apache.
* `apache::dev`: Installs Apache development libraries. (*Note:* On FreeBSD, you must declare `apache::package` or `apache` before `apache::dev`.)
* [`apache::mod::[name]`](#classes-apachemodname): Enables specific Apache HTTPD modules.

####Private Classes

* `apache::confd::no_accf`: Creates the no-accf.conf configuration file in conf.d, required by FreeBSD's Apache 2.4.
* `apache::default_confd_files`: Includes conf.d files for FreeBSD.
* `apache::default_mods`: Installs the Apache modules required to run the default configuration.
* `apache::package`: Installs and configures basic Apache packages.
* `apache::params`: Manages Apache parameters.
* `apache::service`: Manages the Apache daemon.

###Defined Types

####Public Defined Types

* `apache::balancer`: Creates an Apache balancer cluster.
* `apache::balancermember`: Defines members of [mod_proxy_balancer](http://httpd.apache.org/docs/current/mod/mod_proxy_balancer.html).
* `apache::listen`: Based on the title, controls which ports Apache binds to for listening. Adds [Listen](http://httpd.apache.org/docs/current/bind.html) directives to ports.conf in the Apache HTTPD configuration directory. Titles take the form '<port>', '<ipv4>:<port>', or '<ipv6>:<port>'.
* `apache::mod`: Used to enable arbitrary Apache HTTPD modules for which there is no specific `apache::mod::[name]` class.
* `apache::namevirtualhost`: Enables name-based hosting of a virtual host. Adds all [NameVirtualHost](http://httpd.apache.org/docs/current/vhosts/name-based.html) directives to the `ports.conf` file in the Apache HTTPD configuration directory. Titles take the form '\*', '*:<port>', '\_default_:<port>, '<ip>', or '<ip>:<port>'.
* `apache::vhost`: Allows specialized configurations for virtual hosts that have requirements outside the defaults.

####Private Defined Types

* `apache::peruser::multiplexer`: Enables the [Peruser](http://www.freebsd.org/cgi/url.cgi?ports/www/apache22-peruser-mpm/pkg-descr) module for FreeBSD only.
* `apache::peruser::processor`: Enables the [Peruser](http://www.freebsd.org/cgi/url.cgi?ports/www/apache22-peruser-mpm/pkg-descr) module for FreeBSD only.
* `apache::security::file_link`: Links the activated_rules from apache::mod::security to the respective CRS rules on disk.

###Templates

The Apache module relies heavily on templates to enable the `vhost` and `apache::mod` defined types. These templates are built based on Facter facts around your operating system. Unless explicitly called out, most templates are not meant for configuration.

##Limitations

###Ubuntu 10.04

The `apache::vhost::WSGIImportScript` parameter creates a statement inside the VirtualHost which is unsupported on older versions of Apache, causing this to fail.  This will be remedied in a future refactoring.

###RHEL/CentOS 5

The `apache::mod::passenger` and `apache::mod::proxy_html` classes are untested since repositories are missing compatible packages.

###RHEL/CentOS 7

The `apache::mod::passenger` class is untested as the repository does not have packages for EL7 yet.  The fact that passenger packages aren't available also makes us unable to test the `rack_base_uri` parameter in `apache::vhost`.

###General

This module is CI tested on Centos 5 & 6, Ubuntu 12.04 & 14.04, Debian 7, and RHEL 5, 6 & 7 platforms against both the OSS and Enterprise version of Puppet.

The module contains support for other distributions and operating systems, such as FreeBSD, Gentoo and Amazon Linux, but is not formally tested on those and regressions can occur.

###SELinux and Custom Paths

If you are running with SELinux in enforcing mode and want to use custom paths for your `logroot`, `mod_dir`, `vhost_dir`, and `docroot`, you need to manage the context for the files yourself.

Something along the lines of:

```puppet
        exec { 'set_apache_defaults':
          command => 'semanage fcontext -a -t httpd_sys_content_t "/custom/path(/.*)?"',
          path    => '/bin:/usr/bin/:/sbin:/usr/sbin',
          require => Package['policycoreutils-python'],
        }
        package { 'policycoreutils-python': ensure => installed }
        exec { 'restorecon_apache':
          command => 'restorecon -Rv /apache_spec',
          path    => '/bin:/usr/bin/:/sbin:/usr/sbin',
          before  => Class['Apache::Service'],
          require => Class['apache'],
        }
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        file { '/custom/path': ensure => directory, }
        file { '/custom/path/include': ensure => present, content => '#additional_includes' }
        apache::vhost { 'test.server':
          docroot             => '/custom/path',
          additional_includes => '/custom/path/include',
        }
```

You need to set the contexts using `semanage fcontext` not `chcon` because `file {...}` resources reset the context to the values in the database if the resource isn't specifying the context.

###FreeBSD

In order to use this module on FreeBSD, you *must* use apache24-2.4.12 (www/apache24) or newer.

##Development

###Contributing

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

Read the complete module [contribution guide](https://docs.puppetlabs.com/forge/contributing.html)

###Running tests

This project contains tests for both [rspec-puppet](http://rspec-puppet.com/) and [beaker-rspec](https://github.com/puppetlabs/beaker-rspec) to verify functionality. For in-depth information please see their respective documentation.

Quickstart:

####Ruby > 1.8.7

```
    gem install bundler
    bundle install
    bundle exec rake spec
    bundle exec rspec spec/acceptance
    RS_DEBUG=yes bundle exec rspec spec/acceptance
```

####Ruby = 1.8.7

```
    gem install bundler
    bundle install --without system_tests
    bundle exec rake spec
```
