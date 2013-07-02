# = Define apache::htpasswd
#
# This define managed apache htpasswd files
# Based on CamptoCamp Apache module:
# https://github.com/camptocamp/puppet-apache/blob/master/manifests/auth/htpasswd.pp
#
# == Parameters
#
# [*ensure*]
#   Define if the add (present) or remove the user (set as $name)
#   Default: 'present',
#
# [*htpasswd_file*]
#   Path of the htpasswd file to manage.
#   Default: "${apache::params::config_dir}/htpasswd"
#
# [*crypt_password*]
#   Crypted password (as it appears in htpasswd)
#   Default: false (either crypt_password or clear_password must be set)
#  
# [*clear_password*]   
#   Clear password (as it appears in htpasswd)   
#   Default: false (either crypt_password or clear_password must be set)
# 
#
# == Usage
#
# Set clear password='mypass' to user 'my_user' on default htpasswd file:
# apache::htpasswd { 'myuser':
#   clear_password => 'my_pass',
# }
#
# Set crypted password to user 'my_user' on custom htpasswd file:
# apache::htpasswd { 'myuser':
#   crypt_password => 'B5dPQYYjf.jjA',
#   htpasswd_file  => '/etc/httpd/users.passwd',
# }
#
define apache::htpasswd (
  $ensure           = 'present',
  $htpasswd_file    = '',
  $crypt_password   = false,
  $clear_password   = false ) {

  require apache

  $real_htpasswd_file = $htpasswd_file ? {
    ''      => "${apache::params::config_dir}/htpasswd",
    default => $htpasswd_file,
  }

  case $ensure {

    'present': {
      if $crypt_password and $clear_password {
        fail 'Choose only one of crypt_password OR clear_password !'
      }

      if !$crypt_password and !$clear_password  {
        fail 'Choose one of crypt_password OR clear_password !'
      }

      if $crypt_password {
        exec { "test -f ${real_htpasswd_file} || OPT='-c'; htpasswd -bp \${OPT} ${real_htpasswd_file} ${name} '${crypt_password}'":
          unless  => "grep -q ${name}:${crypt_password} ${real_htpasswd_file}",
          path    => '/bin:/sbin:/usr/bin:/usr/sbin',
        }
      }

      if $clear_password {
        exec { "test -f ${real_htpasswd_file} || OPT='-c'; htpasswd -b \$OPT ${real_htpasswd_file} ${name} ${clear_password}":
          unless  => "egrep '^${name}:' ${real_htpasswd_file} && grep ${name}:\$(mkpasswd -S \$(egrep '^${name}:' ${real_htpasswd_file} |cut -d : -f 2 |cut -c-2) ${clear_password}) ${real_htpasswd_file}",
          path    => '/bin:/sbin:/usr/bin:/usr/sbin',
        }
      }
    }

    'absent': {
      exec { "htpasswd -D ${real_htpasswd_file} ${name}":
        onlyif => "egrep -q '^${name}:' ${real_htpasswd_file}",
        notify => Exec["delete ${real_htpasswd_file} after remove ${name}"],
        path   => '/bin:/sbin:/usr/bin:/usr/sbin',
      }

      exec { "delete ${real_htpasswd_file} after remove ${name}":
        command     => "rm -f ${real_htpasswd_file}",
        onlyif      => "wc -l ${real_htpasswd_file} | egrep -q '^0[^0-9]'",
        refreshonly => true,
        path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      }
    }

    default: { }
  }
}
