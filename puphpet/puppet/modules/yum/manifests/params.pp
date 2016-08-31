# = Class yum::params
#
class yum::params  {

  $install_all_keys = false

  $update = false

  $defaultrepo = true

  $extrarepo = 'epel'

  $clean_repos = false

  $plugins_config_dir = '/etc/yum/pluginconf.d'

  $source_repo_dir = undef

  $repo_dir = '/etc/yum.repos.d'

  $config_dir = '/etc/yum'

  $config_file = '/etc/yum.conf'

  $config_file_mode = '0644'

  $config_file_owner = 'root'

  $config_file_group = 'root'

  $log_file = '/var/log/yum.log'

  # parameters for the auto-update classes cron.pp/updatesd.pp
  $update_disable = false

  $update_template = $::operatingsystemrelease ? {
    /6.*/ => 'yum/yum-cron.erb',
    /7.*/ => 'yum/yum-cron-rhel7.erb',
    default => undef,
  }

  $update_configuration_file = $::operatingsystemrelease ? {
    /6.*/ => '/etc/sysconfig/yum-cron',
    /7.*/ => '/etc/yum/yum-cron.conf',
    default => undef,
  }

  # The following param is for cron.pp and is used BOTH for version 6 and 7
  $cron_mailto = ''

  # The following params are for cron.pp only for version 6

  $cron_param = ''
  $cron_dotw = '0123456'

  # The following params are for cron.pp only for version 7

  $cron_update_cmd = 'default'
  $cron_update_messages ='yes'
  $cron_apply_updates = 'yes'
  $cron_random_sleep = '360'
  $cron_emit_via = 'stdio'
  $cron_email_host = 'localhost'

  $source = ''
  $source_dir = ''
  $source_dir_purge = false
  $template = ''
  $options = ''
  $absent = false
  $disable = false
  $disableboot = false
  $puppi = false
  $puppi_helper = 'standard'
  $debug = false
  $audit_only = false
  $priorities_plugin = true

}
