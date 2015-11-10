

#INI file

[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-inifile.png?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-inifile)

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with inifile module](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with inifile](#beginning-with-inifile)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview 

This module adds resource types to manage settings in INI-style configuration files.

##Module Description

The inifile module adds two resource types so that you can use Puppet to manage settings and subsettings in INI-style configuration files. 

This module tries hard not to manipulate your file any more than it needs to. In most cases, it should leave the original whitespace, comments, ordering, etc. intact.

###Noteworthy module features include:

 * Supports comments starting with either '#' or ';'.
 * Supports either whitespace or no whitespace around '='.
 * Adds any missing sections to the INI file.

##Setup

##Beginning with inifile

To manage an INI file, add the resource type `ini_setting` or `ini_subsetting` to a class.

##Usage

Manage individual settings in INI files by adding the `ini_setting` resource type to a class. For example:

```
ini_setting { "sample setting":
  ensure  => present,
  path    => '/tmp/foo.ini',
  section => 'foo',
  setting => 'foosetting',
  value   => 'FOO!',
}
```

To control multiple values in a setting, use `ini_subsetting`. For example:

```
JAVA_ARGS="-Xmx192m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/log/pe-puppetdb/puppetdb-oom.hprof "

ini_subsetting {'sample subsetting':
  ensure  => present,
  section => '',
  key_val_separator => '=',
  path => '/etc/default/pe-puppetdb',
  setting => 'JAVA_ARGS',
  subsetting => '-Xmx',
  value   => '512m',
}
```

###Implementing child providers:

You can set up custom child providers that inherit the `ini_setting` provider. This allows you to implement custom resources to manage INI settings for specific configuration files without copying all the code or writing your own code from scratch. This also allows resource purging to be used.

To implement child providers, you'll need to specify your own type. This type needs to implement a namevar (name) and a property called value:

For example:

```
#my_module/lib/puppet/type/glance_api_config.rb
Puppet::Type.newtype(:glance_api_config) do
  ensurable
  newparam(:name, :namevar => true) do
    desc 'Section/setting name to manage from glance-api.conf'
    # namevar should be of the form section/setting
    newvalues(/\S+\/\S+/)
  end
  newproperty(:value) do
    desc 'The value of the setting to be defined.'
    munge do |v|
      v.to_s.strip
    end
  end
end
```

This type must also have a provider that uses the `ini_setting` provider as its parent. For example:

```
# my_module/lib/puppet/provider/glance_api_config/ini_setting.rb
Puppet::Type.type(:glance_api_config).provide(
  :ini_setting,
  # set ini_setting as the parent provider
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do
  # implement section as the first part of the namevar
  def section
    resource[:name].split('/', 2).first
  end
  def setting
    # implement setting as the second part of the namevar
    resource[:name].split('/', 2).last
  end
  # hard code the file path (this allows purging)
  def self.file_path
    '/etc/glance/glance-api.conf'
  end
end
```

Now the individual settings of the /etc/glance/glance-api.conf file can be managed as individual resources:

```
glance_api_config { 'HEADER/important_config':
  value => 'secret_value',
}
```

If the self.file_path has been implemented, you can purge with the following Puppet syntax:

```
resources { 'glance_api_config'
  purge => true,
}
```

If the above code is added, the resulting configured file will contain only lines implemented as Puppet resources.

##Reference

###Type: ini_setting

#### Parameters

* `ensure`: Ensures that the resource is present. Valid values are 'present', 'absent'.

* `key_val_separator`: The separator string to use between each setting name and value. Defaults to ' = ', but you could use this to override the default (e.g., whether or not the separator should include whitespace).

* `name`: An arbitrary name used as the identity of the resource.

* `path`: The INI file in which Puppet ensures the specified setting.

* `provider`: The specific backend to use for this `ini_setting` resource. You will seldom need to specify this --- Puppet usually discovers the appropriate provider for your platform. The only available provider for `ini_setting` is ruby.

* `section`: The name of the INI file section in which the setting should be defined. Add a global section  --- settings that appear at the beginning of the file, before any named sections --- by specifying a section name of "".

* `setting`: The name of the INI file setting to be defined.

* `value`: The value of the INI file setting to be defined.

###Type: ini_subsetting

#### Parameters

* `ensure`: Ensures that the resource is present. Valid values are 'present', 'absent'.

* `key_val_separator`: The separator string to use between each setting name and value. Defaults to ' = ', but you could use this to override the default (e.g., whether or not the separator should include whitespace).

* `name`: An arbitrary name used as the identity of the resource.

* `path`: The INI file in which Puppet ensures the specified setting.

* `provider`: The specific backend to use for this `ini_subsetting` resource. You will seldom need to specify this --- Puppet usually discovers the appropriate provider for your platform. The only available provider for `ini_subsetting` is ruby.

* `quote_char`: The character used to quote the entire value of the setting. Valid values are '', '"', and "'". Defaults to ''.

* `section`: The name of the INI file section in which the setting should be defined. Add a global section  --- settings that appear at the beginning of the file, before any named sections --- by specifying a section name of "".

* `setting`: The name of the INI file setting to be defined.

* `subsetting`: The name of the INI file subsetting to be defined.

* `subsetting_separator`: The separator string used between subsettings. Defaults to " ".

* `value`: The value of the INI file subsetting to be defined.

##Limitations

This module is officially [supported](https://forge.puppetlabs.com/supported) on :

* Red Hat Enterprise Linux (RHEL) 5, 6, 7
* CentOS 5, 6, 7
* Oracle Linux 5, 6, 7
* Scientific Linux 5, 6, 7
* SLES 11 SP1 or greater
* Debian 6, 7
* Ubuntu 10.04 LTS, 12.04 LTS, 14.04 LTS
* Solaris 10, 11
* Windows Server 2003/2008 R2, 2012/2012 R2 
* AIX 5.3, 6.1, 7.1

This module has also been tested, but is not officially supported, on:

* Red Hat Enterprise Linux (RHEL) 4
* Windows 7
* Mac OSX 10.9 (Mavericks)

### Agent run failure with Puppet Enterprise 

As of Puppet Enterprise 3.3, agent runs on master fail if you are using an older, manually installed version of inifile. To solve this problem, upgrade your inifile module to version 1.1.0 or later. 

##Development
 
Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide on the [Puppet Labs wiki](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing).

##Contributors

The list of contributors can be found at: [https://github.com/puppetlabs/puppetlabs-inifile/graphs/contributors](https://github.com/puppetlabs/puppetlabs-inifile/graphs/contributors).




