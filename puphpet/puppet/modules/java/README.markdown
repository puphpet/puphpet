#java

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with the java module](#setup)
    * [Beginning with the java module](#beginning-with-the-java-module)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

##Overview

Installs the correct Java package on various platforms. 

##Module Description

The java module can automatically install Java jdk or jre on a wide variety of systems. Java is a base component for many software platforms, but Java system packages don't always follow packaging conventions. The java module simplifies the Java installation process.

##Setup

###Beginning with the java module
To install the correct Java package on your system, include the `java` class: `include java`.

##Usage

The java module installs the correct jdk or jre package on a wide variety of systems. By default, the module will install the jdk package, but you can set different installation parameters as needed. For example, to install jre instead of jdk, you would set the distribution parameter:

```
class { 'java':
  distribution => 'jre',
}
```

##Reference

###Classes

####Public classes

* `java`: This is the module's main class, which installs and manages the Java package.

####Private classes

* `java::params`: Builds a hash of jdk/jre packages for all compatible operating systems. 

* `java::config`: Configures the Java alternatives.

###Parameters:

The following parameters are available in the java module:

* `distribution`: The Java distribution to install. Can be 'jdk','jre', or, where the platform supports alternative packages, 'sun-jdk', 'sun-jre', 'oracle-jdk', 'oracle-jre'. Defaults to 'jdk'.

* `version`: The version of Java to install, if you want to ensure a particular version. By default, the module ensures that Java is present but does not require a specific version.

* `package`: The name of the Java package. This is configurable in case you want to install a non-standard Java package. If not set, the module will install the appropriate package for the `distribution` parameter and target platform. If you set `package`, the `distribution` parameter will do nothing. 

* `java_alternative`: The name of the Java alternative to use. The command 'update-java-alternatives -l' will show which choices are available. If you specify a particular package, you will usually want to specify which Java alternative to use. If you set this parameter, you also need to set the `java_alternative_path`.

* `java_alternative_path`: The path to the 'java' command. Since the alternatives system makes it difficult to verify which alternative is actually enabled, this is required to ensure the correct JVM is enabled.

###Facts

The java module includes a few facts to describe the version of Java installed on the system:

* `java_major_version`: The major version of Java.
* `java_patch_level`: The patch level of Java.
* `java_version`: The full Java version string.

**Note:** The facts return `nil` if Java is not installed on the system.

##Limitations

This module cannot guarantee installation of Java versions that are not available on  platform repositories. 

Oracle Java packages are not included in Debian 7 and Ubuntu 12.04/14.04 repositories. To install Java on those systems, you'll need to package Oracle JDK/JRE, and then the module will be able to install the package. For more information on how to package Oracle JDK/JRE, see the [Debian wiki](http://wiki.debian.org/JavaPackage).

This module is officially [supported](https://forge.puppetlabs.com/supported) for the following Java versions and platforms:

OpenJDK is supported on:
* Red Hat Enterprise Linux (RHEL) 5, 6, 7
* CentOS 5, 6, 7
* Oracle Linux 6, 7
* Scientific Linux 5, 6
* Debian 6, 7
* Ubuntu 10.04, 12.04, 14.04
* Solaris 11
* SLES 11 SP1, 12 

Sun Java is supported on:
* Debian 6

##Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide on the [Puppet Labs wiki](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing).

##Contributors

The list of contributors can be found at: [https://github.com/puppetlabs/puppetlabs-java/graphs/contributors](https://github.com/puppetlabs/puppetlabs-java/graphs/contributors).
