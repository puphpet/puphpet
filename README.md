# PuPHPet #

This is the repo for the [PuPHPet.com](https://puphpet.com) website. A proper README is forthcoming!

## Used Puppet Modules ##
* Apache: [https://github.com/example42/puppet-apache](https://github.com/example42/puppet-apache "example42/puppet-apache")
* nginx: [https://github.com/jfryman/puppet-nginx](https://github.com/jfryman/puppet-nginx "jfryman/puppet-nginx")
* MySQL: [https://github.com/puppetlabs/puppetlabs-mysql](https://github.com/puppetlabs/puppetlabs-mysql "puppetlabs/puppetlabs-mysql")
* PostgreSQL: [https://github.com/puppetlabs/puppetlabs-postgresql](https://github.com/puppetlabs/puppetlabs-postgresql "puppetlabs/puppetlabs-postgresql")

## Contribute ##

### Requirements ###
* PHP 5.4
* For executing all the tests [puppet-lint](http://packages.ubuntu.com/precise/puppet-lint) has to be installed on your machine
* some [Silex](http://silex.sensiolabs.org/ "Silex") knowledge

### The all-in-one solution ###
* go to our [quickstart page](https://puphpet.com/quickstart/puphpet "quickstart") and download the vagrant archive
* create a new vagrant box and start it with `vagrant up`
* the provisioning will need some time as the PuPHPet project is directly cloned and installed to `/var/www/puphpet.dev`
* map puphpet.dev to localhost in your hosts file

    127.0.0.1           puphpet.dev

* call puphpet.dev and you should see the project's startpage
* **the quickstart approach is still in beta, feedback is highly appreciated!**

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

    ln -s vendor/phpunit/phpunit/phpunit.php phpunit
    ./phpunit


