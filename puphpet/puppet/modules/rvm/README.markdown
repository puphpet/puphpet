Puppet Module for Ruby Version Manager (RVM)
==============================================

[![Build Status](https://travis-ci.org/maestrodev/puppet-rvm.svg?branch=maestrodev)](https://travis-ci.org/maestrodev/puppet-rvm)
[![Puppet Forge](https://img.shields.io/puppetforge/v/maestrodev/rvm.svg)](https://forge.puppetlabs.com/maestrodev/rvm)
[![Puppet Forge](https://img.shields.io/puppetforge/f/maestrodev/rvm.svg)](https://forge.puppetlabs.com/maestrodev/rvm)

This module handles installing system RVM (also known as multi-user installation
as root) and using it to install rubies and gems.  Support for installing and
configuring passenger is also included.

We are actively using this module.  It works well, but does have some issues you
should be aware of.  Due to the way puppet works, certain resources
(rvm\_sytem\_ruby, rvm\_gem and rvm\_gemset) may generate errors until RVM is
installed.  You may want to use run stages to install RVM before the rest
of your configuration runs.  However, if you run puppet using the `--noop`
parameter, you may see _Could not find a default provider_ errors.  See the
Troubleshooting section for more information.

Please read the troubleshooting section below before opening an issue.


## System Requirements

Puppet 3.0.0 or higher.

## Upgrading

Version 1.5 no longer includes a dependency on puppetlabs/apache, you must install it yourself
if you want to use the passenger module.

## Add Puppet Module

Before you begin, you must add the RVM module to your Puppet installation.  This can be done with:

    $ puppet module install maestrodev/rvm

You may now continue configuring RVM resources.


## Install RVM with Puppet

Install RVM with:

    include rvm

or

    class { 'rvm': version => '1.20.12' }

This will install RVM into `/usr/local/rvm`.

To use RVM without sudo, users need to be added to the `rvm` group.  This can be easily done with:

    rvm::system_user { bturner: ; jdoe: ; jsmith: ; }


## Installing Ruby

You can tell RVM to install one or more Ruby versions with:

    rvm_system_ruby {
      'ruby-1.9':
        ensure      => 'present',
        default_use => true,
        build_opts  => ['--binary'];
      'ruby-2.0':
        ensure      => 'present',
        default_use => false;
    }

You should use the full version number.  While the shorthand version may work (e.g. '1.9.2'), the provider will be unable to detect if the correct version is installed.

If rvm fails to install binary rubies you can increase curl's timeout with the `rvm_max_time_flag` in `~/.rvmrc` with a fully qualified path to the home directory.

    # ensure rvm doesn't timeout finding binary rubies
    # the umask line is the default content when installing rvm if file does not exist
    file { '/home/user/rvmrc':
      content => 'umask u=rwx,g=rwx,o=rx
                  export rvm_max_time_flag=20',
      mode    => '0664',
      before  => Class['rvm'],
    }

Or, to configure `/etc/rvmrc` you can use use `Class['rvm::rvmrc]`

    class{ 'rvm::rvmrc':
      max_time_flag => 20,
      before  => Class['rvm'],
    }

### Installing JRuby from sources

JRuby has some extra requirements, java, maven and ant that you can install using
[puppetlabs/java](http://forge.puppetlabs.com/puppetlabs/java),
[maestrodev/ant](http://forge.puppetlabs.com/maestrodev/ant) and
[maestrodev/maven](http://forge.puppetlabs.com/maestrodev/maven) modules.

    class { 'java': } ->
    class { 'ant': } ->
    class { 'maven::maven': } ->
    rvm_system_ruby { 'jruby-1.7.6':
      ensure      => 'present',
      default_use => false;
    }


## Creating Gemsets

Create a gemset with:

    rvm_gemset {
      'ruby-1.9.3-p448@myproject':
        ensure  => present,
        require => Rvm_system_ruby['ruby-1.9.3-p448'];
    }


## Installing Gems

Install a gem with:

    rvm_gem {
      'ruby-1.9.3-p448@myproject/bundler':
        ensure  => '1.0.21',
        require => Rvm_gemset['ruby-1.9.3-p448@myproject'];
    }

The *name* of the gem should be `<ruby-version>[@<gemset>]/<gemname>`.  For example, you can install bundler for ruby-1.9.2 using `ruby-1.9.3-p448/bundler`.  You could install rails in your project's gemset with: `ruby-1.9.3-p448@myproject/rails`.

Alternatively, you can use this more verbose syntax:

    rvm_gem {
      'bundler':
        name         => 'bundler',
        ruby_version => 'ruby-1.9.3-p448',
        ensure       => latest,
        require      => Rvm_system_ruby['ruby-1.9.3-p448'];
    }

## Creating Aliases

To create an RVM alias, you can use:

    rvm_alias {
      'myproject':
        target_ruby => 'ruby-1.9.3-p448@myproject',
        ensure      => present,
        require     => Rvm_gemset['ruby-1.9.3-p448@myproject'];
    }

## Creating Wrappers

To create an RVM wrapper, you can use:

    rvm_wrapper {
      'god':
        target_ruby => 'ruby-1.9.3-p448',
        prefix      => 'bootup',
        ensure      => present,
        require     => Rvm_system_ruby['ruby-1.9.3-p448'];
    }

## Installing Passenger

NOTE: You must install the [puppetlabs/apache](http://forge.puppetlabs.com/puppetlabs/apache) module by yourself.
It is not included as a dependency to this module to avoid installing it when is not needed most times.

Install passenger using the [puppetlabs/apache](http://forge.puppetlabs.com/puppetlabs/apache) module,
and using:

    class { 'apache': }
    class { 'rvm::passenger::apache':
        version            => '3.0.11',
        ruby_version       => 'ruby-1.9.3-p448',
        mininstances       => '3',
        maxinstancesperapp => '0',
        maxpoolsize        => '30',
        spawnmethod        => 'smart-lv2',
    }

## Using Hiera

You can configure the ruby versions to be installed and the system users from hiera

    rvm::system_rubies:
      '1.9':
        default_use: true
      '2.0': {}
      'jruby-1.7': {}

    rvm::system_users:
      - john
      - doe

    rvm::rvm_gems:
      'bundler':
        name: 'bundler'
        ruby_version: '1.9'
        ensure: latest


## Building the module

Testing is done with rspec, [Beaker-rspec](https://github.com/puppetlabs/beaker-rspec), [Beaker](https://github.com/puppetlabs/beaker))

To test and build the module

    bundle install
    # run specs
    rake

    # run Beaker system tests with vagrant vms
    rake beaker
    # to use other vm from the list spec/acceptance/nodesets and not destroy the vm after the tests
    BEAKER_destroy=no BEAKER_set=centos-64-x64 bundle exec rake beaker

    # Release the Puppet module to the Forge, doing a clean, build, tag, push, bump_commit and git push
    rake module:release

## Troubleshooting / FAQ

### An error "Could not find a default provider for rvm\_system\_ruby" is displayed when running Puppet with --noop

This means that puppet cannot find the `/usr/local/rvm/bin/rvm` command
(probably because RVM isn't installed yet).  Currently, Puppet does not support
making a provider suitable using another resource (late-binding).  You may want
to use run stages to install RVM before the rest of the
configuration runs.  When running in _noop_ mode, RVM is not actually installed
causing rvm\_system\_ruby, rvm\_gem and rvm\_gemset resources to generate this
error.  You can avoid this error by surrounding your rvm configuration in an if
block:

    if $rvm_installed == "true" {
        rvm_system_ruby ...
    }

Do not surround `include rvm` in the if block, as this is used to install RVM.

NOTE: $rvm\_installed is evaluated at the beginning of each puppet run.  If you
use this in your manifests, you will need to run puppet twice to fully
configure RVM.

### An error "Resource type rvm_gem does not support parameter false" prevents puppet from running.

The RVM module requires Puppet version 2.6.7 or higher.

There is a bug in Puppet versions 2.7.4 through 2.7.9 that also causes this
error.  The error can be safely ignored in these versions.  For best results,
upgrade to Puppet 2.7.10.


### Some packages/libraries I don't want or need are installed (e.g. build-essential, libc6-dev, libxml2-dev).

RVM works by compiling Ruby from source.  This means you must have all the libraries and binaries required to compile Ruby installed on your system, which is handled by rvm autolibs in newer versions of RVM.


### It doesn't work on my operating system.

Check the rspec-system tests as described above to test in a specific OS
If that doesn't work feel free to send a pull request ;)


### Why didn't you just add an RVM provider for the existing package type?

The puppet [package](http://docs.puppetlabs.com/references/latest/type.html#package)
type seems like an obvious place for the RVM provider.  It would be nice if the syntax
for installing Ruby with RVM looked like:

    # NOTE: This does not work
    package {'ruby':
        provider => 'rvm',
        ensure => '1.9.2-p290';
    }

While this may be possible, it becomes harder to manage multiple Ruby versions and
nearly impossible to install gems for a specific Ruby version.  For this reason,
I decided it was best to create a completely new set of types for RVM.

