# Adds non-free repos to Debian
# A bit hacky but works well
#
# This depends on
#   puppetlabs/apt: https://github.com/puppetlabs/puppetlabs-apt

class puphpet::debian::non_free (
  $release = $::lsbdistcodename
) {

  $sources_list = '/etc/apt/sources.list'

  $deb_srcs = [
    "deb http://http.us.debian.org/debian ${release} main",
    "deb-src http://http.us.debian.org/debian ${release} main",
    "deb http://security.debian.org/ ${release}/updates main",
    "deb-src http://security.debian.org/ ${release}/updates main",
    "deb http://http.us.debian.org/debian ${release}-updates main",
    "deb-src http://http.us.debian.org/debian ${release}-updates main",
    "deb http://http.debian.net/debian ${release} main",
    "deb-src http://http.debian.net/debian ${release} main",
    "deb http://http.debian.net/debian ${release}-updates main",
    "deb-src http://http.debian.net/debian ${release}-updates main",
  ]

  each( $deb_srcs ) |$value| {
    exec { "add contrib non-free to ${value}":
      command => "perl -p -i -e 's#${value}#${value} contrib non-free#gi' ${sources_list}",
      onlyif  => "grep -x '${value}' ${sources_list}",
      path    => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
      notify  => Exec['apt_update'],
    }
  }

}
