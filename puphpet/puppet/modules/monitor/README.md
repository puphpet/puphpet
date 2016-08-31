# Puppet module: monitor

This is a Puppet abstraction module to manage monitoring.

Made by Alessandro Franceschi / Lab42 - http://www.example42.com

Released under the terms of Apache 2 License.

Check Modulefile for dependencies.

## Goal of this module
This module abstracts the monitoring definitions for an host or application, in order to add and use different monitoring methods, without changes on the single application modules.

It's used, as an option disabled by default, in the Example42 modules and provides:

* a common interface for different monitoring tools (Nagios, Monit, Munin....)

* an unified syntax for monitoring resources able to adapt to monitoring modules from different authors

* a standard way to define what an application or an host needs to be monitored

* reversable actions (you can remove a monitor resource previously defined)

## Usage
In order to activate automatic monitoring for the resources defined in a class you have to pass, at least, these parameters:

        class { "foo":
          monitor      => true,
          monitor_tool => [ "nagios" , "monit" , "munin" ],
        }

where monitor_tool is an array of the monitor tools you want to activate to automatically check the resources provided the defined class.

In Example42 modules, when monitoring is active,  for applications that provide network services, is activated the monitoring of the listening port and the running process, with a syntax like this:

        monitor::port { "foo_${foo::protocol}_${foo::port}": 
          protocol => "${foo::protocol}",
          port     => "${foo::port}",
          target   => "${foo::params::monitor_target_real}",
          tool     => "${foo::monitor_tool}",
          enable   => $foo::manage_monitor,
        }

        monitor::process { "foo_process":
          process  => "${foo::process}",
          service  => "${foo::service}",
          pidfile  => "${foo::pidfile}",
          tool     => "${foo::monitor_tool}",
          enable   => $foo::manage_monitor,
        }

Modules related to web applications generally have a monitor::url define that checks for a specifyed pattern string in an given url:

        monitor::url { "foo_webapp_url":
          url     => "${foo_webapp::url_check}",
          pattern => "${foo_webapp::url_pattern}",
          port    => "${foo_webapp::port}",
          target  => "${fqdn}",
          tool    => "${foo_webapp::monitor_tool}",
          enable  => $foo_webapp::manage_monitor,
        }

## Monitor module layout 
This monitor module is to be considered a (working) implementation, entirely based on Puppet's DSL of a (strongly needed) monitor abstraction type.
The generic monitor defines are placed in files like:

        monitor/manifests/process.pp
        monitor/manifests/port.pp
        monitor/manifests/url.pp

here according to the monitor_tool requested are called some specific defines relevant to the requested monitoring tools.
Note that here you can choose different implementations of monitoring modules, so you are free to change the whole module to be used for a specific monitoring tool editing just these few files.  

## Dependencies
This is a meta-module that needs dependencies according to the monitor tools modules you use.
It also requires Example42's puppi module.
IMPORTANT: You must have storeconfigs enabled on your PuppetMaster to use monitoring tools that involve a central server, like Nagios or Munin.
