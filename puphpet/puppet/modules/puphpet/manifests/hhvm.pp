# This depends on
#   puppetlabs/apt: https://github.com/puppetlabs/puppetlabs-apt
#   example42/puppet-yum: https://github.com/example42/puppet-yum
#   puppetlabs/puppetlabs-apache: https://github.com/puppetlabs/puppetlabs-apache (if apache)

class puphpet::hhvm(
  $nightly = false,
) {

  if $nightly == true {
    $package_name_base = $puphpet::params::hhvm_package_name_nightly
  } else {
    $package_name_base = $puphpet::params::hhvm_package_name
  }

  if $nightly == true and $::osfamily == 'Redhat' {
    warning('HHVM-nightly is not available for RHEL distros. Falling back to normal release')
  }

  case $::operatingsystem {
    'debian': {
      if $::lsbdistcodename != 'wheezy' {
        fail('Sorry, HHVM currently only works with Debian 7+.')
      }

      include ::puphpet::debian::non_free
    }
    'ubuntu': {
      if ! ($lsbdistcodename in ['precise', 'raring', 'trusty']) {
        fail('Sorry, HHVM currently only works with Ubuntu 12.04, 13.10 and 14.04.')
      }

      apt::key { '5D50B6BA': key_server => 'hkp://keyserver.ubuntu.com:80' }

      if $lsbdistcodename in ['lucid', 'precise'] {
        apt::ppa { 'ppa:mapnik/boost': require => Apt::Key['5D50B6BA'], options => '' }
      }
    }
    'centos': {
      $require = defined(Class['puphpet::firewall::post']) ? {
        true    => Class['puphpet::firewall::post'],
        default => [],
      }

      package { 'jemalloc':
        ensure   => latest,
        provider => yum,
      }

      yum::managed_yumrepo { 'hop5':
        descr    => 'hop5 repository',
        baseurl  => 'http://www.hop5.in/yum/el6/',
        gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-HOP5',
        enabled  => 1,
        gpgcheck => 0,
        priority => 1,
      }
    }
  }

  $os = downcase($::operatingsystem)

  case $::osfamily {
    'debian': {
      apt::key { 'hhvm':
        key        => '16d09fb4',
        key_source => 'http://dl.hhvm.com/conf/hhvm.gpg.key',
      }

      apt::source { 'hhvm':
        location          => "http://dl.hhvm.com/${os}",
        repos             => 'main',
        required_packages => 'debian-keyring debian-archive-keyring',
        include_src       => false,
        require           => Apt::Key['hhvm']
      }
    }
  }

  if ! defined(Package[$package_name_base]) {
    package { $package_name_base:
      ensure => present
    }
  }

}
