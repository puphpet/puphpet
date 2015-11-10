# Composer Puppet Module

[![Build Status](https://travis-ci.org/tPl0ch/puppet-composer.png?branch=master)](https://travis-ci.org/tPl0ch/puppet-composer)

## Description

The `puppet-composer` module installs the latest version of Composer from http://getcomposer.org. Composer is a dependency manager for PHP.

## Supported Puppet versions

This module supports puppet in versions `>= 2.7, <3.5`

## Supported Platforms

* `Debian`
* `Ubuntu`
* `Redhat`
* `Centos`
* `Amazon Linux`

## Installation

#### Puppet Forge
We recommend installing using the Puppet Forge as it automatically satisfies dependencies.

    puppet module install --target-dir=/your/path/to/modules tPl0ch-composer

#### Installation via git submodule
You can also install as a git submodule and handle the dependencies manually. See the [Dependencies](#dependencies) section below.

    git submodule add git://github.com/tPl0ch/puppet-composer.git modules/composer

## Dependencies

This module requires the following Puppet modules:

* [`puppetlabs-git`](https://github.com/puppetlabs/puppetlabs-git/)

And additional (for puppet version lower than 3.0.0) you need:

* [`libaugeas`](http://augeas.net/) (For automatically updating php.ini settings for suhosin patch)
* [`hiera-puppet`](http://docs.puppetlabs.com/hiera/1/installing.html#step-2-install-the-puppet-functions) (For managing config data)

## Usage
To install the `composer` binary globally in `/usr/local/bin` you only need to declare the `composer` class. We try to set some sane defaults. There are also a number of parameters you can tweak should the defaults not be sufficient.

### Simple Include
To install the binary with the defaults you just need to include the following in your manifests:

    include composer

### Full Include
Alternatively, you can set a number of options by declaring the class with parameters:

```puppet
class { 'composer':
    target_dir      => '/usr/local/bin',
    composer_file   => 'composer', # could also be 'composer.phar'
    download_method => 'curl',     # or 'wget'
    logoutput       => false,
    tmp_path        => '/tmp',
    php_package     => 'php5-cli',
    curl_package    => 'curl',
    wget_package    => 'wget',
    composer_home   => '/root',
    php_bin         => 'php', # could also i.e. be 'php -d "apc.enable_cli=0"' for more fine grained control
    suhosin_enabled => true,
    auto_update     => false, # Set to true to automatically update composer to the latest version
    github_token    => '1234567890abcdefgh',
    user            => 'app',
}
```

### Creating Projects

The `composer::project` definition provides a way to create projects in a target directory.

```puppet
composer::project { 'silex':
    project_name   => 'fabpot/silex-skeleton',  # REQUIRED
    target_dir     => '/vagrant/silex', # REQUIRED
    version        => '2.1.x-dev', # Some valid version string
    prefer_source  => true,
    stability      => 'dev', # Minimum stability setting
    keep_vcs       => false, # Keep the VCS information
    dev            => true, # Install dev dependencies
    repository_url => 'http://repo.example.com', # Custom repository URL
    user           => undef, # Set the user to run as
}
```

### Updating Packages

The `composer::exec` definition provides a more generic wrapper arround composer `update` and `install` commands. The following example will update the `silex/silex` and `symfony/browser-kit` packages in the `/vagrant/silex` directory. You can omit `packages` to update the entire project.

```puppet
composer::exec { 'silex-update':
    cmd                  => 'update',  # REQUIRED
    cwd                  => '/vagrant/silex', # REQUIRED
    packages             => ['silex/silex', 'symfony/browser-kit'], # leave empty or omit to update whole project
    prefer_source        => false, # Only one of prefer_source or prefer_dist can be true
    prefer_dist          => false, # Only one of prefer_source or prefer_dist can be true
    dry_run              => false, # Just simulate actions
    custom_installers    => false, # No custom installers
    scripts              => false, # No script execution
    interaction          => false, # No interactive questions
    optimize             => false, # Optimize autoloader
    dev                  => true, # Install dev dependencies
    timeout              => undef, # Set a timeout for the exec type
    user                 => undef, # Set the user to run as
    refreshonly          => false, # Only run on refresh
}
```

### Installing Packages

We support the `install` command in addition to `update`. The install command will ignore the `packages` parameter and the following example is the equivalent to running `composer install` in the `/vagrant/silex` directory.

```puppet
composer::exec { 'silex-install':
    cmd                  => 'install',  # REQUIRED
    cwd                  => '/vagrant/silex', # REQUIRED
    prefer_source        => false,
    prefer_dist          => false,
    dry_run              => false, # Just simulate actions
    custom_installers    => false, # No custom installers
    scripts              => false, # No script execution
    interaction          => false, # No interactive questions
    optimize             => false, # Optimize autoloader
    dev                  => true, # Install dev dependencies
    onlyif               => undef, # If true
    unless               => undef, # If true
}
```

### Updating composer

You can use the defined type `composer::selfupdate` to update (or rollback) composer to the latest (or specific) version.

```puppet
composer::selfupdate { 'selfupdate_composer':
  version       => undef, # Leave undef for latest version, otherwise specify commit hash here
  rollback      => false, # Set to true to rollback to a specified version (version MUST be given)
  clean_backups => false, # Set to true to clean backups
  user          => undef, # If the command should be run as a user
  logoutput     => false, # If the command's output should be written to the logs
  timeout       => 300,   # Timeout for this command
  tries         => 3,     # Retries for this command
}
```

## Development

For unit testing we use `rspec-puppet` and Travis CI. Functional testing happens through a Vagrant VM where you can test changes in a real server scenario.

### Unit Tests

When contributing fixes or features you should try and create RSpec tests for those changes. It is always a good idea to make sure the entire suite passes before opening a pull request. To run the RSpec tests locally you need `bundler` installed:

```
gem install bundler
```

Then you can install the required gems:

```
bundle install
```

Finally, the tests can be run:

```
rake spec
```

### Functional Tests

For easier development and actual testing the use of the module, we rely on Vagrant, which allows us to bring up a VM that we can use to test changes and perform active development without needing a real server.

To get started with the Vagrant VM you should first get the [Unit Tests](#unit-tests) working. Then you will need to install [VirtualBox][virtualbox] and [Vagrant][vagrant].

To bring up the development VM you can run `rake vagrant:up`. This Rake task runs `rake spec_prep` as a pre-requisite so that the `git` Puppet module is available. With the VM up and running you can login via SSH with `vagrant ssh` and run `puppet apply` against it with `rake vagrant:provision`.

The VM will get the `spec/fixtures/manifests/vagrant.pp` file applied to the node. This currently creates a Silex project at `/tmp/silex` when the VM starts up. You can modify this manifest to your liking.

### Acceptance Tests

Acceptance tests are written using [Beaker](https://github.com/puppetlabs/beaker/wiki).

To run the beaker tests via rake, you can simply run `rake beaker`.

To use something other than the default beaker node, try the following:

```
BEAKER_set=ubuntu-server-1404-x64 rake beaker
```

To use beaker without rake, simply run `rspec spec/acceptance`.

**Beaker + Hiera**

When running acceptance tests, you may hit GitHub rate limits much faster than you would otherwise. To ensure your tests do not fail arbitrarily, you can add your GitHub auth token via hiera.

Create a hiera config at `spec/fixtures/puppet/common.yaml`, that looks like this:

```yaml
composer::github_token: 'my_github_auth_token'
```

Happy testing!

## Contributing

We welcome everyone to help develop this module. To contribute:

* Fork this repository
* Add features and spec tests for them
* Commit to feature named branch
* Open a pull request outlining your changes and the reasoning for them

## Todo

* Add a `composer::require` type

[vagrant]: http://vagrantup.com/
[virtualbox]: https://www.virtualbox.org/wiki/Downloads
