# Class: solr
#
# This is the main solr class
#
#
# == Parameters
#
# Standard class parameters - Define solr web app specific settings
#
# [*install*]
#   Kind of installation to attempt:
#     - package : Installs solr using the OS common packages
#     - source  : Installs solr downloading and extracting a specific tarball or zip file
#     - puppi   : Installs solr tarball or file via Puppi, creating the "puppi deploy solr" command
#
# [*install_source*]
#   The URL from where to retrieve the source tarball/zip. Used if install => "source" or "puppi"
#   Default is from upstream developer site. Update the version when needed.
#
# [*install_destination*]
#   The base path where to extract the source tarball/zip. Used if install => "source" or "puppi"
#   By default is the distro's default DocumentRoot for Web or Application server
#
# [*install_precommand*]
#   A custom command to execute before installing the source tarball/zip. Used if install => "source" or "puppi"
#   Check solr/manifests/params.pp before overriding the default settings
#
# [*install_postcommand*]
#   A custom command to execute after installing the source tarball/zip. Used if install => "source" or "puppi"
#   Check solr/manifests/params.pp before overriding the default settings
#
# [*url_check*]
#   An url, relevant to the solr application, to use for testing the correct deployment of solr.
#   Used is monitor is enabled.
#
# [*url_pattern*]
#   A string that must exist in the defined url_check that confirms that the application is running correctly
#
#
# Standard class parameters - Define the general class behaviour and customizations
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, solr class will automatically "include $my_class"
#
# [*source*]
#   Sets the content of source parameter for main configuration file
#   If defined, solr main config file will have the parameter: source => $source
#
# [*source_dir*]
#   If defined, the whole solr configuration directory content is retrieved recursively from
#   the specified source (parameter: source => $source_dir , recurse => true)
#
# [*source_dir_purge*]
#   If set to true all the existing configuration directory is overriden by the
#   content retrived from source_dir. (source => $source_dir , recurse => true , purge => true)
#
# [*template*]
#   Sets the path to the template to be used as content for main configuration file
#   If defined, solr main config file will have: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#
# [*options*]
#   An hash of custom options that can be used in templates for arbitrary settings.
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#
# [*monitor*]
#   Set to 'true' to enable monitoring of the services provided by the module
#
# [*monitor_tool*]
#   Define which monitor tools (ad defined in Example42 monitor module) you want to use for solr
#
# [*puppi*]
#   Set to 'true' to enable creation of module data files that are used by puppi
#
# [*debug*]
#   Set to 'true' to enable modules debugging
#
#
# Default class params - As defined in solr::params.
# Note that these variables are mostly defined and used in the module itself, overriding the default
# values might not affected all the involved components (ie: packages layout)
# Set and override them only if you know what you're doing.
#
# [*package*]
#   The name of solr package
#
# [*config_dir*]
#   Main configuration directory. Used by puppi
#
# [*config_file*]
#   Main configuration file path
#
# [*config_file_mode*]
#   Main configuration file path mode
#
# [*config_file_owner*]
#   Main configuration file path owner
#
# [*config_file_group*]
#   Main configuration file path group
#
# [*data_dir*]
#   Path of application data directory. Used by puppi
#
# [*log_dir*]
#   Base logs directory. Used by puppi
#
# [*log_file*]
#   Log file(s). Used by puppi
#
#
# == Examples
#
# See README
#
#
# == Author
#   Alessandro Franceschi <al@lab42.it/>
#
class solr (
  $install             = params_lookup( 'install' ),
  $install_source      = params_lookup( 'install_source' ),
  $install_destination = params_lookup( 'install_destination' ),
  $install_precommand  = params_lookup( 'install_precommand' ),
  $install_postcommand = params_lookup( 'install_postcommand' ),
  $url_check           = params_lookup( 'url_check' ),
  $url_pattern         = params_lookup( 'url_pattern' ),
  $my_class            = params_lookup( 'my_class' ),
  $source              = params_lookup( 'source' ),
  $source_dir          = params_lookup( 'source_dir' ),
  $source_dir_purge    = params_lookup( 'source_dir_purge' ),
  $template            = params_lookup( 'template' ),
  $options             = params_lookup( 'options' ),
  $absent              = params_lookup( 'absent' ),
  $monitor             = params_lookup( 'monitor' ),
  $monitor_tool        = params_lookup( 'monitor_tool' ),
  $puppi               = params_lookup( 'puppi' ),
  $debug               = params_lookup( 'debug' ),
  $package             = params_lookup( 'package' ),
  $config_dir          = params_lookup( 'config_dir' ),
  $config_file         = params_lookup( 'config_file' ),
  $config_file_mode    = params_lookup( 'config_file_mode' ),
  $config_file_owner   = params_lookup( 'config_file_owner' ),
  $config_file_group   = params_lookup( 'config_file_group' ),
  $data_dir            = params_lookup( 'data_dir' ),
  $log_dir             = params_lookup( 'log_dir' ),
  $log_file            = params_lookup( 'log_file' ),
  ) inherits solr::params {

  validate_bool($source_dir_purge, $absent , $monitor , $puppi , $debug)

  # Calculations of some variables used in the module
  $manage_package = $solr::absent ? {
    true  => 'absent',
    false => 'present',
  }

  $manage_file = $solr::absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_monitor = $solr::absent ? {
    true  => false ,
    default => $solr::disable ? {
      true    => false,
      default => true,
    }
  }


  # Installation is managed in dedicated class
  require solr::install

  file { 'solr.conf':
    ensure  => $solr::manage_file,
    path    => $solr::config_file,
    mode    => $solr::config_file_mode,
    owner   => $solr::config_file_owner,
    group   => $solr::config_file_group,
    require => Class['solr::install'],
    source  => $source ? {
      ''      => undef,
      default => $source,
    },
    content => $template ? {
      ''      => undef,
      default => template($template),
    },
  }

  # Whole solr configuration directory can be recursively overriden
  if $solr::source_dir {
    file { 'solr.dir':
      ensure  => directory,
      path    => $solr::config_dir,
      require => Class['solr::install'],
      source  => $source_dir,
      recurse => true,
      purge   => $source_dir_purge,
    }
  }

  # Include custom class if $my_class is set
  if $solr::my_class {
    include $solr::my_class
  }


  # Provide puppi data, if enabled ( puppi => true )
  if $solr::puppi == true {
    $puppivars=get_class_args()
    file { 'puppi_solr':
      ensure  => $solr::manage_file,
      path    => "${settings::vardir}/puppi/solr",
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => Class['puppi'],
      content => inline_template('<%= puppivars.to_yaml %>'),
    }
  }


  # Url check, if enabled ( monitor => true )
  if $solr::monitor == true and $solr::url_check != '' {
    monitor::url { 'solr_url':
      enable  => $solr::manage_monitor,
      url     => $solr::url_check,
      pattern => $solr::url_pattern,
      port    => $solr::port,
      target  => $::fqdn,
      tool    => $solr::monitor_tool,
    }
  }


  # Include debug class is debugging is enabled
  if $solr::debug == true {
    file { 'debug_solr':
      ensure  => $solr::manage_file,
      path    => "${settings::vardir}/debug-solr",
      mode    => '0640',
      owner   => 'root',
      group   => 'root',
      content => inline_template('<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime.*|path|timestamp|free|.*password.*|.*psk.*|.*key)/ }.to_yaml %>'),
    }
  }

}
