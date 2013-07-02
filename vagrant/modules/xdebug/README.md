puppet-xdebug
=============

Puppet module for installing XDEBUG PHP Extension

Installs XDEBUG Support.
Depends on (tested with)
 - https://github.com/camptocamp/puppet-php.git

Example usage:

    include xdebug

Advanced configuration:

    xdebug::config { 'default':
        remote_host => '169.254.0.1', # Vagrant users can specify their address
        remote_port => '9000', # Change default settings 
    }

Author: Stefan Kögel

GitHub: git@github.com:stkoegel/puppet-xdebug.git

Changelog:

* Version 0.1 - Initial Commit for Debian/Ubuntu and three config values
* Version 0.2 - Add xdebug configuration options

ToDo:
- add support for RedHat and other os