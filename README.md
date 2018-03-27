# PuPHPet #

[PuPHPet](https://puphpet.com) - A simple GUI to set up virtual machines for PHP development

[![Build Status](https://travis-ci.org/puphpet/puphpet.png)](https://travis-ci.org/puphpet/puphpet) [![Code Climate](https://codeclimate.com/github/puphpet/puphpet/badges/gpa.svg)](https://codeclimate.com/github/puphpet/puphpet)

## What? ##

[PuPHPet](https://puphpet.com) is a web application that allows you to easily and quickly generate custom
[Vagrant](http://vagrantup.com) and [Puppet](https://puppetlabs.com) controlled virtual machines.

If you're unfamiliar with either Vagrant or Puppet, I wrote a blog titled
["Make $ vagrant up yours"](https://jtreminio.com/2013/06/make_vagrant_up_yours/).

## How? ##

PHP drives the frontend, using the ["Symfony2 framework"](http://symfony.com/). Choices are set into a yaml file that
configures the main Puppet manifest with your custom settings.

## Why? ##

I started using Vagrant and Puppet when I wanted a simple PHP 5.4 VM to do my development on. I could find nothing
pre-made that didn't come with a bunch of cruft I did not want so I decided to create a tool that would ease this
task for other developers who may not want to learn Puppet's DSL to get a VM up and running so they can develop
in their language of choice.

## Who? ##

Originally developed by [Juan Treminio](https://jtreminio.com), PuPHPet has now had 29 contributors (as of 12/15/13),
with the talented [Frank Stelzer](https://twitter.com/frastel) heavily contributing. Also making significant
contributions is [Michaël Perrin](http://www.michaelperrin.fr/).

Sometime in mid August 2013, work on v2 was begun to attempt to solve problems encountered with v1: difficult to
add new features, too much PHP logic controlling Puppet logic, difficult to change an existing manifest.

## Goals ##

The main goal of PuPHPet is to eventually replace tools such as XAMPP, WAMPP, MAMPP and other all-in-one servers that
create development environments on your main operating system.

Eventually PuPHPet will be good enough to help create production-ready servers!

## Requirements ##

To run PuPHPet-generated manifests, you'll need to install [Vagrant](https://www.vagrantup.com/downloads.html)
version 2.0.0 or greater. Vagrant will run on Windows, OS X and Linux.

## Contribution ##

If you have a patch, or stumbled upon an issue with PuPHPet core, you can contribute this back to the code. Please read our [contributor guidelines](https://github.com/puphpet/puphpet/blob/master/CONTRIBUTING.md) for more information how you can do this.

## License ##

PuPHPet is licensed under the [MIT license](http://opensource.org/licenses/mit-license.php) all third-party Puppet

Modules are licensed under [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0).

Clearmin Design licensed under GPLv3 with
[an exemption provided for PuPHPet](https://github.com/puphpet/puphpet/blob/master/LICENSE-DESIGN.md).
