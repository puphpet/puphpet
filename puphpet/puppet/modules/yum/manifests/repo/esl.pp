# = Class: yum::repo::esl
#
# This class installs the esl repo
#
class yum::repo::esl (
  $baseurl = 'http://packages.erlang-solutions.com/rpm/centos/$releasever/$basearch',
) {

  yum::managed_yumrepo { 'esl':
    descr          => 'Erlang Solutions',
    baseurl        => $baseurl,
    enabled        => 1,
    gpgcheck       => 0,
    gpgkey         => 'http://packages.erlang-solutions.com/rpm/erlang_solutions.asc',
    priority       => 10,
  }

}
