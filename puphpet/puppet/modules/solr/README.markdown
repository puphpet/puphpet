# Puppet module: solr

This is a Puppet solr module from the second generation of Example42 Puppet Modules.

Made by Alessandro Franceschi / Lab42 - http://www.example42.com

Released under the terms of Apache 2 License.

Check Modulefile for dependencies.

Development has been sponsored by Elce - http://www.elce.us


## USAGE - Basic management
* Install solr with default settings

        class { "solr": }

* Remove solr 

        class { "solr":
          absent => true,
        }

* Define solr installation method: Valid values for install => are "package" (default), "source" and "puppi".

        class { "solr":
          install => "source",
        }

* Install source from a custom url to a custom install_destination path.
  The following parameters apply both for "source" and "puppi" install methods.
  Puppi method may be used to manage deployment updates (given the $install_source is updated).
  By default install_source is set to upstream developer and install_destination to Web (App) server document root
  Pre and post installation commands may be already defined (check solr/manifests/params.pp) override them only if needed.
  Url_check and url_pattern are used for application checks, if monitor is enabled. Override only if needed.

        class { "solr":
          install             => "source",
          install_source      => "http://deploy.example42.com/solr/solr.tar.gz",
          install_destination => "/opt/apps/",
          # install_precommand  => "...",
          # install_postcommand => "...",
          # url_check           => "...",
          # url_pattern         => "...",
        }



## USAGE - Overrides and Customizations
* Use custom sources for main config file 

        class { "solr":
          source => [ "puppet:///modules/lab42/solr/solr.conf-$hostname" , "puppet:///modules/lab42/solr/solr.conf" ], 
        }

* Use custom template for main config file 

        class { "solr":
          template => "example42/solr/solr.conf.erb",      
        }

* Define custom options that can be used in a custom template without the
  need to add parameters to the solr class

        class { "solr":
          template => "example42/solr/solr.conf.erb",    
          options  => {
            'LogLevel' => 'INFO',
            'UsePAM'   => 'yes',
          },
        }

* Automaticallly include a custom subclass

        class { "solr:"
          my_class => 'lab42::solr',
        }


## USAGE - Example42 extensions management 
* Activate puppi (recommended, but disabled by default)
  Note that this option requires the usage of Example42 puppi module

        class { "solr": 
          puppi    => true,
        }

* Activate automatic monitoring (recommended, but disabled by default)
  This option requires the usage of Example42 monitor and relevant monitor tools modules

        class { "solr":
          monitor      => true,
          monitor_tool => [ "nagios" , "monit" , "munin" ],
        }

