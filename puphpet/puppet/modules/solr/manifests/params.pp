# Class: solr::params
#
# This class defines default parameters used by the main module class solr
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to solr class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class solr::params {

  # Default installation type depends on OS package availability
  $install = $::operatingsystem ? {
    /(?i:Ubuntu|Debian|Mint)/ => 'package',
    default                   => 'source',
  }

  # Install source from the upstream provider is updated
  # to module's last update time
  # You may need to change this: use the "install_source" parameter
  # of the solr class
  $install_source = 'http://www.apache.org/dist/lucene/solr/3.4.0/apache-solr-3.4.0.tgz'

  $install_destination = $::operatingsystem ? {
    default                   => '/opt/solr',
  }

  $install_precommand  = ''

  $install_postcommand = ''

  $url_check           = "${::fqdn}/solr"

  $url_pattern         = 'Welcome to Solr!'

  $my_class            = ''
  $source              = ''
  $source_dir          = ''
  $source_dir_purge    = false
  $template            = ''
  $options             = ''
  $absent              = false
  $monitor             = false
  $monitor_tool        = ''
  $puppi               = false
  $debug               = false

  $package = $::operatingsystem ? {
    /(?i:Ubuntu|Debian|Mint)/ => 'solr-tomcat',
    default                   => 'solr',
  }

  $config_dir = $::operatingsystem ? {
    default => '/etc/solr/conf',
  }

  $config_file = $::operatingsystem ? {
    default => '/etc/solr/conf/solrconfig.xml',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  $data_dir = $::operatingsystem ? {
    default => '/var/lib/solr',
  }

  $log_dir = $::operatingsystem ? {
    default => '/var/log',
  }

  $log_file = $::operatingsystem ? {
    default => '/var/log/solr.log',
  }

}
