Installation
===================

This is the repo for the [PuPHPet.com](https://puphpet.com) website. A proper README is forthcoming!

Using Vagrant for Development?
------------------------------
**Steps to get up and running**

1. Download and install [Vagrant 1.1+](http://www.vagrantup.com) and [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
1. Navigate to the \[Project_Root\]/vagrant folder
1. Run the command ```vagrant up --provider virtualbox```
1. Navigate to 192.168.1.12 in your browser
1. Eureka, you can start developing!!

Requirements
------------
* PHP 5.4
* For executing all the tests [puppet-lint](http://packages.ubuntu.com/precise/puppet-lint) has to be installed on your machine

Used Puppet Modules
===================

jfryman/puppet-nginx
--------------------
* URL: [https://github.com/jfryman/puppet-nginx](https://github.com/jfryman/puppet-nginx "jfryman/puppet-nginx")
* Used for nginx installation.

puppetlabs/postgresql
---------------------
* URL: [https://github.com/puppetlabs/puppet-postgresql](https://github.com/puppetlabs/puppet-postgresql "puppetlabs/puppet-postgresql")
* Used for PostgreSQL installation.

*Repository jfryman/puppet-nginx will be switched to original repository as soon as
the introduction of composer.json is merged there.
http://getcomposer.org/doc/05-repositories.md#vcs*
