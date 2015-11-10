# = Class: yum::defaults
#
# This class manages default yum repositories for RedHat based distros:
# RHEL, Centos, Scientific Linux
#
class yum::defaults ( ) inherits yum::params {

  $osver = split($::operatingsystemrelease, '[.]')

  if 'epel' in $yum::extrarepo { include yum::repo::epel }
  if 'rpmforge' in $yum::extrarepo { include yum::repo::rpmforge }
  if 'jpackage5' in $yum::extrarepo { include yum::repo::jpackage5 }
  if 'jpackage6' in $yum::extrarepo { include yum::repo::jpackage6 }
  if 'remi' in $yum::extrarepo { include yum::repo::remi }
  if 'remi_php55' in $yum::extrarepo { include yum::repo::remi_php55 }
  if 'remi_php56' in $yum::extrarepo { include yum::repo::remi_php56 }
  if 'tmz' in $yum::extrarepo and $osver[0] != '4' { include yum::repo::tmz }
  if 'webtatic' in $yum::extrarepo { include yum::repo::webtatic }
  if 'puppetlabs' in $yum::extrarepo and $osver[0] != '4' { include yum::repo::puppetlabs }
  if 'puppetdevel' in $yum::extrarepo and $osver[0] != '4' { include yum::repo::puppetdevel }
  if 'nginx' in $yum::extrarepo and $osver[0] != '4' { include yum::repo::nginx }
  if 'mongodb' in $yum::extrarepo and $osver[0] != '4' { include yum::repo::mongodb }
  if 'repoforge' in $yum::extrarepo { include yum::repo::repoforge }
  if 'repoforgeextras' in $yum::extrarepo { include yum::repo::repoforgeextras }
  if 'integ_ganeti' in $yum::extrarepo { include yum::repo::integ_ganeti }
  if 'elrepo' in $yum::extrarepo { include yum::repo::elrepo }
  if 'newrelic' in $yum::extrarepo { include yum::repo::newrelic }
  if 'mod_pagespeed' in $yum::extrarepo { include yum::repo::mod_pagespeed }
  if 'jenkins' in $yum::extrarepo { include yum::repo::jenkins }
  if 'centalt' in $yum::extrarepo { include yum::repo::centalt }
  if 'elastix' in $yum::extrarepo { include yum::repo::elastix }
  if 'mysql_community' in $yum::extrarepo { include yum::repo::mysql_community }

  if $yum::bool_defaultrepo {
    case $::operatingsystem {
      centos: {
        if $osver[0] == '6' { include yum::repo::centos6 }
        if $osver[0] == '5' { include yum::repo::centos5 }
        if $osver[0] == '4' { include yum::repo::centos4 }
        if 'centos-testing' in $yum::extrarepo { include yum::repo::centos_testing }
        if 'karan' in $yum::extrarepo { include yum::repo::karan }
        if 'atomic' in $yum::extrarepo { include yum::repo::atomic }
      }
      redhat: {
      }
      scientific: {
        if $osver[0] == '6' { include yum::repo::sl6 }
        if $osver[0] == '5' { include yum::repo::sl5 }
        if 'centos-testing' in $yum::extrarepo { include yum::repo::centos_testing }
        if 'karan' in $yum::extrarepo { include yum::repo::karan }
      }
      default: { }
    }
  }
}
