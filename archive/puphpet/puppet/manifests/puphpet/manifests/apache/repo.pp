class puphpet::apache::repo {

  if $::operatingsystem == 'debian' {
    include ::puphpet::apache::repo::debian
  }

  if $::operatingsystem == 'ubuntu' {
    include ::puphpet::apache::repo::ubuntu
  }

  if $::osfamily == 'redhat' {
    include ::puphpet::apache::repo::centos
  }

}
