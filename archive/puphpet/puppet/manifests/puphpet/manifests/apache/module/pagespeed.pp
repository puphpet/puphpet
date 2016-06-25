# This depends on puppetlabs/apache: https://github.com/puppetlabs/puppetlabs-apache

class puphpet::apache::module::pagespeed {

  include ::apache::params
  include ::puphpet::apache::params

  $apache = $puphpet::params::hiera['apache']

  $download_location = $::osfamily ? {
    'Debian' => '/.puphpet-stuff/mod-pagespeed.deb',
    'Redhat' => '/.puphpet-stuff/mod-pagespeed.rpm'
  }

  $provider = $::osfamily ? {
    'Debian' => 'dpkg',
    'Redhat' => 'rpm'
  }

  puphpet::server::wget { $download_location:
    source => $puphpet::apache::params::mod_pagespeed_url,
  }
  -> package { $puphpet::apache::params::mod_pagespeed_package:
    ensure   => present,
    provider => $provider,
    source   => $download_location,
    notify   => Service['httpd']
  }

  file { "${::apache::params::mod_dir}/pagespeed.conf":
    purge => false,
  }

  if $::apache::params::mod_enable_dir != undef {
    file { "${::apache::params::mod_enable_dir}/pagespeed.conf":
      purge => false,
    }
  }

  $pagespeed_load = "${::apache::params::mod_dir}/pagespeed.load"

  exec { 'mod_pagespeed httpd 2.4':
    command => "perl -p -i -e 's#mod_pagespeed.so#mod_pagespeed_ap24.so#gi' ${pagespeed_load}",
    onlyif  => "test -f ${pagespeed_load}",
    unless  => "grep -x 'mod_pagespeed_ap24.so' ${pagespeed_load}",
    path    => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
    notify  => Service['httpd']
  }

}
