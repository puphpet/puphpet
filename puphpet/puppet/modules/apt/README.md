# apt

## Overview

The apt module provides a simple interface for managing Apt source, key, and definitions with Puppet.

## Module Description

The apt module automates obtaining and installing software packages on \*nix systems.

**Note**: While this module allows the use of short keys, **warnings are thrown if a full fingerprint is not used**, as they pose a serious security issue by opening you up to collision attacks.

## Setup

### What apt affects:

* Package/service/configuration files for Apt
* Your system's `sources.list` file and `sources.list.d` directory
* System repositories
* Authentication keys

**Note**: Setting the apt module's `purge_sources_list` and `purge_sources_list_d` parameters to 'true' will **destroy** any existing content that was not declared with Puppet. The default for these parameters is 'false'.

### Beginning with apt

To begin using the apt module with default parameters, declare the class with `include apt`.

Any Puppet code that uses anything from the apt module requires that the core apt class be declared.

## Usage

Using the apt module consists predominantly of declaring classes and defined types that provide the desired functionality and features. This module provides common resources and options that are shared by the various defined types in the apt module, so you **must always** include this class in your manifests.

```
class { 'apt':
  always_apt_update    => false,
  apt_update_frequency => undef,
  disable_keys         => undef,
  proxy_host           => false,
  proxy_port           => '8080',
  purge_sources_list   => false,
  purge_sources_list_d => false,
  purge_preferences_d  => false,
  update_timeout       => undef,
  fancy_progress       => undef
}
```

## Reference

### Classes

* `apt`: Main class, provides common resources and options. Allows Puppet to manage your system's sources.list file and sources.list.d directory, but it does its best to respect existing content.

  If you declare your apt class with `purge_sources_list`, `purge_sources_list_d`, `purge_preferences` and `purge_preferences_d` set to 'true', Puppet will unapologetically purge any existing content it finds that wasn't declared with Puppet.
  
* `apt::backports`: This class adds the necessary components to get backports for Ubuntu and Debian. The release name defaults to `$lsbdistcodename`. Setting this manually can cause undefined and potentially serious behavior.

  By default, this class drops a pin-file for backports, pinning it to a priority of 200. This is lower than the normal Debian archive, which gets a priority of 500 to ensure that packages with `ensure => latest` don't get magically upgraded from backports without your explicit permission.

  If you raise the priority through the `pin_priority` parameter to 500---identical to the rest of the Debian mirrors---normal policy goes into effect, and Apt installs or upgrades to the newest version. This means that if a package is available from backports, it and its dependencies are pulled in from backports unless you explicitly set the `ensure` attribute of the `package` resource to `installed`/`present` or a specific version.

* `apt::params`: Sets defaults for the apt module parameters.

* `apt::release`: Sets the default Apt release. This class is particularly useful when using repositories that are unstable in Ubuntu, such as Debian.

  ```
  class { 'apt::release':
    release_id => 'precise',
  }
  ```  

* `apt::unattended_upgrades`: This class manages the unattended-upgrades package and related configuration files for Ubuntu and Debian systems. You can configure the class to automatically upgrade all new package releases or just security releases.

  ```
  class { 'apt::unattended_upgrades':
    blacklist     => [],
    update        => '1',
    download      => '1',
    upgrade       => '1',
    autoclean     => '7',
  }
  ```
  
* `apt::update`: Runs `apt-get update`, updating the list of available packages and their versions without installing or upgrading any packages. The update runs on the first Puppet run after you include the class, then whenever `notify  => Exec['apt_update']` occurs; i.e., whenever config files get updated or other relevant changes occur. If you set the `always_apt_update` parameter to 'true', the update runs on every Puppet run.

### Types

* `apt_key`

  A native Puppet type and provider for managing GPG keys for Apt is provided by this module.

  ```
  apt_key { 'puppetlabs':
    ensure => 'present',
    id     => '1054B7A24BD6EC30',
  }
  ```

  You can additionally set the following attributes:

   * `source`: HTTP, HTTPS or FTP location of a GPG key or path to a file on the target host.
   * `content`: Instead of pointing to a file, pass the key in as a string.
   * `server`: The GPG key server to use. It defaults to *keyserver.ubuntu.com*.
   * `keyserver_options`: Additional options to pass to `--keyserver`.

  Because apt_key is a native type, you can use it and query for it with MCollective. 

### Defined Types

* `apt::builddep`: Installs the build dependencies of a specified package.

  `apt::builddep { 'glusterfs-server': }`
    
* `apt::conf`: Specifies a custom configuration file. The priority defaults to 50, but you can set the priority parameter to load the file earlier or later. The content parameter passes specified content, if any, into the file resource.

* `apt::hold`: Holds a specific version of a package. You can hold a package to a full version or a partial version.

  To set a package's ensure attribute to 'latest' but get the version specified by `apt::hold`:

  ```
  apt::hold { 'vim':
    version => '2:7.3.547-7',
  }
  ```

  Alternatively, if you want to hold your package at a partial version, you can use a wildcard. For example, you can hold Vim at version 7.3.*:


  ```
  apt::hold { 'vim':
    version => '2:7.3.*',
  }
  ```

* `apt::force`: Forces a package to be installed from a specific release. This is particularly useful when using repositories that are unstable in Ubuntu, such as Debian.

  ```
  apt::force { 'glusterfs-server':
    release     => 'unstable',
    version     => '3.0.3',
    cfg_files   => 'unchanged',
    cfg_missing => true,
    require => Apt::Source['debian_unstable'],
  }
  ```

  Valid values for `cfg_files` are:
    * 'new': Overwrites all existing configuration files with newer ones.
    * 'old': Forces usage of all old files.
    * 'unchanged: Updates only unchanged config files.
    * 'none': Provides backward-compatibility with existing Puppet manifests.
   
  Valid values for `cfg_missing` are 'true', 'false'. Setting this to 'false' provides backward compatibility; setting it to 'true' checks for and installs missing configuration files for the selected package.

* `apt::key`: Adds a key to the list of keys used by Apt to authenticate packages. This type uses the aforementioned `apt_key` native type. As such, it no longer requires the `wget` command on which the old implementation depended.

  ```
  apt::key { 'puppetlabs':
    key        => '1054B7A24BD6EC30',
    key_server => 'pgp.mit.edu',
  }

  apt::key { 'jenkins':
    key        => '9B7D32F2D50582E6',
    key_source => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
  }
  ```

* `apt::pin`: Defined type that adds an Apt pin for a certain release.

  ```
  apt::pin { 'karmic': priority => 700 }
  apt::pin { 'karmic-updates': priority => 700 }
  apt::pin { 'karmic-security': priority => 700 }
  ```

  Note that you can also specify more complex pins using distribution properties.

  ```
  apt::pin { 'stable':
    priority        => -10,
    originator      => 'Debian',
    release_version => '3.0',
    component       => 'main',
    label           => 'Debian'
  }
  ```  

  If you want to pin a number of packages, you can specify the packages as a space-delimited string using the `packages` attribute, or you can pass in an array of package names.

* `apt::ppa`: Adds a PPA repository using `add-apt-repository`. For example, `apt::ppa { 'ppa:drizzle-developers/ppa': }`.

* `apt::source`: Adds an Apt source to `/etc/apt/sources.list.d/`. For example:

  ```
  apt::source { 'debian_unstable':
    comment           => 'This is the iWeb Debian unstable mirror',
    location          => 'http://debian.mirror.iweb.ca/debian/',
    release           => 'unstable',
    repos             => 'main contrib non-free',
    required_packages => 'debian-keyring debian-archive-keyring',
    key               => 'A1BD8E9D78F7FE5C3E65D8AF8B48AD6246925553',
    key_server        => 'subkeys.pgp.net',
    pin               => '-10',
    include_src       => true,
    include_deb       => true
  }
  ```  

  For example, to configure your system so the source is the Puppet Labs Apt repository:

  ```
  apt::source { 'puppetlabs':
    location   => 'http://apt.puppetlabs.com',
    repos      => 'main',
    key        => '1054B7A24BD6EC30',
    key_server => 'pgp.mit.edu',
    }
  ```

### Facts

The apt module includes a few facts to describe the state of the Apt system:

* `apt_updates`: The number of updates available on the system
* `apt_security_updates`: The number of updates which are security updates
* `apt_package_updates`: The package names that are available for update. In Facter 2.0 and later, this will be a list type; in earlier versions, it is a comma-delimited string.
* `apt_update_last_success`: The date, in epochtime, of the most recent successful `apt-get update` run. This is determined by reading the mtime of  /var/lib/apt/periodic/update-success-stamp.

**Note:** The facts depend on 'update-notifier' being installed on your system. Though this is a GNOME daemon only the support files are needed so the package 'update-notifier-common' is enough to enable this functionality.

#### Hiera example

```
<pre>
apt::sources:
  'debian_unstable':
    location: 'http://debian.mirror.iweb.ca/debian/'
    release: 'unstable'
    repos: 'main contrib non-free'
    required_packages: 'debian-keyring debian-archive-keyring'
    key: '9AA38DCD55BE302B'
    key_server: 'subkeys.pgp.net'
    pin: '-10'
    include_src: true
    include_deb: true

  'puppetlabs':
    location: 'http://apt.puppetlabs.com'
    repos: 'main'
    key: '1054B7A24BD6EC30'
    key_server: 'pgp.mit.edu'
</pre>
```

### Parameters

#### apt

* `always_apt_update`: Set to 'true' to update Apt on every run. This setting is intended for development environments where package updates are frequent. Defaults to 'false'. 
* `apt_update_frequency`: Sets the run frequency for `apt-get update`. Defaults to 'reluctantly'. Accepts the following values:
  * 'always': Runs update at every Puppet run.
  * 'daily': Runs update daily; that is, `apt-get update` runs if the value of `apt_update_last_success` is less than current epoch time - 86400. If the exec resource `apt_update` is notified, `apt-get update` runs regardless of this value. 
  * 'weekly': Runs update weekly; that is, `apt-get update` runs if the value of `apt_update_last_success` is less than current epoch time - 604800. If the exec resource `apt_update` is notified, `apt-get update` runs regardless of this value. 
  * 'reluctantly': Only runs `apt-get update` if the exec resource `apt_update` is notified. This is the default setting.  
* `disable_keys`: Disables the requirement for all packages to be signed.
* `proxy_host`: Configures a proxy host and stores the configuration in /etc/apt/apt.conf.d/01proxy.
* `proxy_port`: Configures a proxy port and stores the configuration in /etc/apt/apt.conf.d/01proxy.
* `purge_sources_list`: If set to 'true', Puppet purges all unmanaged entries from sources.list. Accepts 'true' or 'false'. Defaults to 'false'.
* `purge_sources_list_d`: If set to 'true', Puppet purges all unmanaged entries from sources.list.d. Accepts 'true' or 'false'. Defaults to 'false'.
* `update_timeout`: Overrides the exec timeout in seconds for `apt-get update`. Defaults to exec default (300).
* `update_tries`: Sets how many times to attempt running `apt-get update`. Use this to work around transient DNS and HTTP errors. By default, the command runs only once.
* `sources`: Passes a hash to create_resource to make new `apt::source` resources.
* `fancy_progress`: Enables fancy progress bars for apt. Accepts 'true', 'false'. Defaults to 'false'.

####apt::unattended_upgrades

* `legacy_origin`: If set to true, use the old `Unattended-Upgrade::Allowed-Origins` variable. If false, use `Unattended-Upgrade::Origins-Pattern`. OS-dependent defaults are defined in `apt::params`.
* `origins`: The repositories from which to automatically upgrade included packages.
* `blacklist`: A list of packages to **not** automatically upgrade.
* `update`: How often, in days, to run `apt-get update`.
* `download`: How often, in days, to run `apt-get upgrade --download-only`.
* `upgrade`: How often, in days, to upgrade packages included in the origins list.
* `autoclean`: How often, in days, to run `apt-get autoclean`.
* `randomsleep`: How long, in seconds, to randomly wait before applying upgrades.

####apt::source

* `comment`: Add a comment to the apt source file.
* `ensure`: Allows you to remove the apt source file. Can be 'present' or 'absent'.
* `location`: The URL of the apt repository.
* `release`: The distribution of the apt repository. Defaults to fact 'lsbdistcodename'.
* `repos`: The component of the apt repository. This defaults to 'main'.
* `include_deb`: References a Debian distribution's binary package.
* `include_src`: Enable the deb-src type, references a Debian distribution's source code in the same form as the include_deb type. A deb-src line is required to fetch source indexes.
* `required_packages`: install required packages via an exec. defaults to 'false'.
* `key`: See apt::key
* `key_server`: See apt::key
* `key_content`: See apt::key
* `key_source`: See apt::key
* `pin`: See apt::pin
* `architecture`: can be used to specify for which architectures information should be downloaded. If this option is not set all architectures defined by the APT::Architectures option will be downloaded. Defaults to 'undef' which means all. Example values can be 'i386' or 'i386,alpha,powerpc'.
* `trusted_source` can be set to indicate that packages from this source are always authenticated even if the Release file is not signed or the signature can't be checked. Defaults to false. Can be 'true' or 'false'.

####apt::key

* `ensure`: The state we want this key in. Can be 'present' or 'absent'.
* `key`: Is a GPG key ID or full key fingerprint. This value is validated with a regex enforcing it to only contain valid hexadecimal characters, be precisely 8 or 16 hexadecimal characters long and optionally prefixed with 0x for key IDs, or 40 hexadecimal characters long for key fingerprints.
* `key_content`: This parameter can be used to pass in a GPG key as a string in case it cannot be fetched from a remote location and using a file resource is for other reasons inconvenient.
* `key_source`: This parameter can be used to pass in the location of a GPG key. This URI can take the form of a `URL` (ftp, http or https) and a `path` (absolute path to a file on the target system).
* `key_server`: The keyserver from where to fetch our GPG key. It can either be a domain name or URL. It defaults to undef which results in apt_key's default keyserver being used, currently `keyserver.ubuntu.com`.
* `key_options`: Additional options to pass on to `apt-key adv --keyserver-options`.

####apt::pin

* `ensure`: The state we want this pin in. Can be 'present' or 'absent'.
* `explanation`: Add a comment. Defaults to `${caller_module_name}: ${name}`.
* `order`: The order of the file name. Defaults to '', otherwise must be an integer.
* `packages`: The list of packages to pin. Defaults to '\*'. Can be an array or string. 
* `priority`: Several versions of a package may be available for installation when the sources.list(5) file contains references to more than one distribution (for example, stable and testing). APT assigns a priority to each version that is available. Subject to dependency constraints, apt-get selects the version with the highest priority for installation.
* `release`: The Debian release. Defaults to ''. Typical values can be 'stable', 'testing' and 'unstable'.
* `origin`: Can be used to match a hostname. The following record will assign a high priority to all versions available from the server identified by the hostname. Defaults to ''.
* `version`: The specific form assigns a priority (a "Pin-Priority") to one or more specified packages with a specified version or version range.
* `codename`: The distribution (lsbdistcodename) of the apt repository. Defaults to ''.
* `release_version`: Names the release version. For example, the packages in the tree might belong to Debian release version 7. Defaults to ''.
* `component`: Names the licensing component associated with the packages in the directory tree of the Release file. defaults to ''. Typical values can be 'main', 'dependencies' and 'restricted'
* `originator`: Names the originator of the packages in the directory tree of the Release file. Defaults to ''. Most commonly, this is Debian.
* `label`: Names the label of the packages in the directory tree of the Release file. Defaults to ''. Most commonly, this is Debian.

**Note**: Parameters release, origin, and version are mutually exclusive.

It is recommended to read the manpage 'apt_preferences(5)'

####apt::ppa

* `ensure`: Whether we are adding or removing the PPA. Can be 'present' or 'absent'. Defaults to 'present'.
* `release`: The codename for the operating system you're running. Defaults to `$lsbdistcodename`. Required if lsb-release is not installed.
* `options`: Options to be passed to the `apt-add-repository` command. OS-dependent defaults are set in `apt::params`.
* `package_name`: The package that provides the `apt-add-repository` command. OS-dependent defaults are set in `apt::params`.
* `package_manage`: Whether or not to manage the package providing `apt-add-repository`. Defaults to true.

### Testing

The apt module is mostly a collection of defined resource types, which provide reusable logic for managing Apt. It provides smoke tests for testing functionality on a target system, as well as spec tests for checking a compiled catalog against an expected set of resources.

#### Example Test

This test sets up a Puppet Labs Apt repository. Start by creating a new smoke test, called puppetlabs-apt.pp, in the apt module's test folder. In this test, declare a single resource representing the Puppet Labs Apt source and GPG key:

```
apt::source { 'puppetlabs':
  location   => 'http://apt.puppetlabs.com',
  repos      => 'main',
  key        => '1054B7A24BD6EC30',
  key_server => 'pgp.mit.edu',
}
```    

This resource creates an Apt source named puppetlabs and gives Puppet information about the repository's location and the key used to sign its packages. Puppet leverages Facter to determine the appropriate release, but you can set this directly by adding the release type.

Check your smoke test for syntax errors:

`$ puppet parser validate tests/puppetlabs-apt.pp`

If you receive no output from that command, it means nothing is wrong. Then, apply the code:

```
$ puppet apply --verbose tests/puppetlabs-apt.pp
notice: /Stage[main]//Apt::Source[puppetlabs]/File[puppetlabs.list]/ensure: defined content as '{md5}3be1da4923fb910f1102a233b77e982e'
info: /Stage[main]//Apt::Source[puppetlabs]/File[puppetlabs.list]: Scheduling refresh of Exec[puppetlabs apt update]
notice: /Stage[main]//Apt::Source[puppetlabs]/Exec[puppetlabs apt update]: Triggered 'refresh' from 1 events>
```    

The above example uses a smoke test to lay out a resource declaration and apply it on your system. In production, you might want to declare your Apt sources inside the classes where they’re needed.

Limitations
-----------

This module should work across all versions of Debian/Ubuntu and support all major Apt repository management features.

Development
------------

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)

License
-------

The original code for this module comes from Evolving Web and was licensed under the MIT license. Code added since the fork of this module is licensed under the Apache 2.0 License like the rest of the Puppet Labs products.

The LICENSE contains both licenses.

Contributors
------------

A lot of great people have contributed to this module. A somewhat current list follows:

* Ben Godfrey <ben.godfrey@wonga.com>
* Branan Purvine-Riley <branan@puppetlabs.com>
* Christian G. Warden <cwarden@xerus.org>
* Dan Bode <bodepd@gmail.com> <dan@puppetlabs.com>
* Daniel Tremblay <github@danieltremblay.ca>
* Garrett Honeycutt <github@garretthoneycutt.com>
* Jeff Wallace <jeff@evolvingweb.ca> <jeff@tjwallace.ca>
* Ken Barber <ken@bob.sh>
* Matthaus Litteken <matthaus@puppetlabs.com> <mlitteken@gmail.com>
* Matthias Pigulla <mp@webfactory.de>
* Monty Taylor <mordred@inaugust.com>
* Peter Drake <pdrake@allplayers.com>
* Reid Vandewiele <marut@cat.pdx.edu>
* Robert Navarro <rnavarro@phiivo.com>
* Ryan Coleman <ryan@puppetlabs.com>
* Scott McLeod <scott.mcleod@theice.com>
* Spencer Krum <spencer@puppetlabs.com>
* William Van Hevelingen <blkperl@cat.pdx.edu> <wvan13@gmail.com>
* Zach Leslie <zach@puppetlabs.com>
* Daniele Sluijters <github@daenney.net>
* Daniel Paulus <daniel@inuits.eu>
* Wolf Noble <wolf@wolfspyre.com>
