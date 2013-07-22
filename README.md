# PuPHPet #

[PuPHPet](https://puphpet.com) - A simple GUI to set up virtual machines for PHP development

[![Build Status](https://travis-ci.org/puphpet/puphpet.png)](https://travis-ci.org/puphpet/puphpet)

## What? ##

[PuPHPet](https://puphpet.com) is a web application that allows you to easily and quickly generate custom
[Vagrant](http://vagrantup.com) and [Puppet](https://puppetlabs.com) controlled virtual machines.

If you're unfamiliar with either Vagrant or Puppet, I wrote a blog titled
["Make $ vagrant up yours"](https://jtreminio.com/2013/06/make_vagrant_up_yours/).

## How? ##

Built on top of the great [Silex](http://silex.sensiolabs.org) framework, we use PHP to generate a custom Vagrantfile
and Puppet manifest with your custom choices.

## Why? ##

I started using Vagrant and Puppet when I wanted a simple PHP 5.4 VM to do my development on. I could find nothing
pre-made that didn't come with a bunch of cruft I did not want so I decided to create a tool that would ease this
task for other developers who may not want to learn Puppet's DSL to get a VM up and running so they can develop
in their language of choice.

## Who? ##

Originally developed by [Juan Treminio](https://jtreminio.com), PuPHPet has now had 15 contributors with the talented
[Frank Stelzer](https://twitter.com/frastel) heavily contributing. Also making significant contributions is
[Michaël Perrin](http://www.michaelperrin.fr/).

## Goals ##

The main goal of PuPHPet is to eventually replace tools such as XAMPP, WAMPP, MAMPP and other all-in-one servers that
create development environments on your main operating system.

Eventually PuPHPet will be good enough to help create production-ready servers!

## Requirements ##

To run PuPHPet-generated manifests, you'll need to install [Vagrant](http://downloads.vagrantup.com/) version 1.2.0 or
greater. Vagrant will run on Windows, OS X and Linux.

## Contribute ##

### Requirements ###
* PHP 5.4
* For executing all the tests [puppet-lint](http://packages.ubuntu.com/precise/puppet-lint) has to be installed on your machine
* some [Silex](http://silex.sensiolabs.org/ "Silex") knowledge

### The all-in-one solution ###
* go to our [quickstart page](https://puphpet.com/quickstart/puphpet "quickstart") and download the vagrant archive
* create a new vagrant box and start it with `$ vagrant up`
* the provisioning will need some time as the PuPHPet project is directly cloned and installed to `/var/www/puphpet.dev`
* map puphpet.dev to localhost in your hosts file

    `127.0.0.1           puphpet.dev`

* call puphpet.dev and you should see the project's startpage
* **the quickstart approach is still in beta, feedback is highly appreciated!**

For creating a patch you have to fork the project and within the box you have to do:

    cd /var/www/puphpet.dev
    git remote add fork git@github.com:<your username here>/puphpet.git
    git checkout -b my-patch
    # git add ...
    # git commit -m "some patch"
    git push fork my-patch

### For existing environments ###
* PuPHPet will work on any default LAMP or LNMP environment
* go to our [quickstart page](https://puphpet.com/quickstart/puphpet "quickstart") and download the vagrant archive
* when you have already a running environment please have a look at the generated `manifest/default.pp` file and especially to the package list
* ensure that the required packages are installed on your system
* clone the project from github
* and install it with composer

Setup:

    mkdir -p /var/www/puphpet.dev
    cd /var/www/puphpet.dev
    git clone git@github.com:puphpet/puphpet.git .
    composer install --dev

### Run the tests ###
Before you create a PR you should go sure that everything works well and you didn't break anything.
Running the tests is quite simple as PHPUnit is already installed by Composer and you only have to call its runner.

    $ ./vendor/bin/phpunit

## Used third-party Puppet Modules ##
* PHP: [https://github.com/example42/puppet-php](https://github.com/example42/puppet-php "example42/puppet-php")
* Apache: [https://github.com/example42/puppet-apache](https://github.com/example42/puppet-apache "example42/puppet-apache")
* nginx: [https://github.com/jfryman/puppet-nginx](https://github.com/jfryman/puppet-nginx "jfryman/puppet-nginx")
* MySQL: [https://github.com/puppetlabs/puppetlabs-mysql](https://github.com/puppetlabs/puppetlabs-mysql "puppetlabs/puppetlabs-mysql")
* PostgreSQL: [https://github.com/puppetlabs/puppetlabs-postgresql](https://github.com/puppetlabs/puppetlabs-postgresql "puppetlabs/puppetlabs-postgresql")

## License ##

PuPHPet is licensed under the [MIT license](http://opensource.org/licenses/mit-license.php) all third-party Puppet Modules are licensed under [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0).
