# = Class: yum::repo::elasticsearch90
#
# This class installs the elasticsearch90 repo
#
class yum::repo::elasticsearch90 (
  $baseurl = 'http://packages.elasticsearch.org/elasticsearch/0.90/centos',
) {

  yum::managed_yumrepo { 'elasticsearch-0.90':
    descr          => 'Elasticsearch repository for 0.90.x packages',
    baseurl        => $baseurl,
    enabled        => 1,
    gpgcheck       => 1,
    gpgkey         => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
  }

}
