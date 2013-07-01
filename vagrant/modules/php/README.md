# Puppet module: php

This is a Puppet module for php based on the second generation layout ("NextGen") of Example42 Puppet Modules.

Made by ALessandro Franceschi / Lab42

Official site: http://www.example42.com

Official git repository: http://github.com/lermit/puppet-php

Released under the terms of Apache 2 License.

This module requires functions provided by the Example42 Puppi module (you need it even if you don't use and install Puppi)

For detailed info about the logic and usage patterns of Example42 modules check the DOCS directory on Example42 main modules set.

## USAGE - Basic management

* Install php with default settings

        class { 'php': }

* Install a specific version of php package

        class { 'php':
          version => '1.0.1',
        }

* Remove php package

        class { 'php':
          absent => true
        }

* Enable auditing without without making changes on existing php configuration files

        class { 'php':
          audit_only => true
        }

## USAGE - Module installation

* Install a new module

        php::module { "imagick": }

* Install a specific version of a module:

        php::module { "imagick":
          version => '1.0.1';
        }

* Remove php module

        php::module { "imagick":
            absent => true,
        }

* By default module package name is php-$title for RedHat and php5-$title . You can override this prefix.

        php::module { "apc": 
          module_prefix => "php-"
        }


## USAGE - Pear Management

* Install a pear package 

        php::pear::module { "XML_Util": }

* Install a pear package from a remote repository

        php::pear::module { 'PHPUnit':
          repository  => 'pear.phpunit.de',
          use_package => 'no',
        }

* Set a config option 

        php::pear::config { http_proxy: value => "myproxy:8080" }


## USAGE - Pecl Management

* Install a pecl package

        php::pecl::module { "XML_Util": }

* Set a config option 

        php::pecl::config { http_proxy: value => "myproxy:8080" }


## USAGE - Overrides and Customizations
* Use custom sources for main config file

        class { 'php':
          source => [ "puppet:///modules/lab42/php/php.conf-${hostname}" , "puppet:///modules/lab42/php/php.conf" ],
        }


* Use custom source directory for the whole configuration dir

        class { 'php':
          source_dir       => 'puppet:///modules/lab42/php/conf/',
          source_dir_purge => false, # Set to true to purge any existing file not present in $source_dir
        }

* Use custom template for main config file. Note that template and source arguments are alternative.

        class { 'php':
          template => 'example42/php/php.conf.erb',
        }

* Automatically include a custom subclass

        class { 'php':
          my_class => 'php::example42',
        }





[![Build Status](https://travis-ci.org/example42/puppet-php.png?branch=master)](https://travis-ci.org/example42/puppet-php)
