class puphpet::solr::install {

  include ::solr::params

  exec { 'create solr conf dir':
    command => "mkdir -p ${solr::params::config_dir}",
    creates => $solr::params::config_dir,
    path    => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
  }

  if ! defined(Class['java']) {
    class { 'java':
      distribution => 'jre',
    }
  }

}
