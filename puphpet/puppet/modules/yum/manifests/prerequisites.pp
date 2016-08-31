# = Class yum::prerequisites
#
class yum::prerequisites {

  require yum

  if $yum::bool_priorities_plugin == true {
    yum::plugin { 'priorities': }
  }
#  yum::plugin { 'security': }

  if $yum::bool_install_all_keys == true {
    file { 'rpm_gpg':
      path    => '/etc/pki/rpm-gpg/',
      source  => "puppet:///modules/yum/${::operatingsystem}.${yum::osver[0]}/rpm-gpg/",
      recurse => true,
      ignore  => '.svn',
      mode    => '0644',
      owner   => root,
      group   => 0,
    }
  }
}
