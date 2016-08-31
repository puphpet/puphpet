# = Class: yum::repo::logstash13
#
# This class installs the logstash13 repo
#
class yum::repo::logstash13 (
  $baseurl = 'http://packages.elasticsearch.org/logstash/1.3/centos',
) {

  yum::managed_yumrepo { 'logstash-1.3':
    descr          => 'logstash repository for 1.3.x packages',
    baseurl        => $baseurl,
    enabled        => 1,
    gpgcheck       => 1,
    gpgkey         => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
  }

}
