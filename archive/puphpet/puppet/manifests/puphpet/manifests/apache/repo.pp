class puphpet::apache::repo {

  if $::operatingsystem == 'debian' {
    class{ 'puphpet::apache::repo::debian': }
  }

  if $::operatingsystem == 'ubuntu' {
    class{ 'puphpet::apache::repo::ubuntu': }
  }

  if $::osfamily == 'redhat' {
    class{ 'puphpet::apache::repo::centos': }
  }

}
