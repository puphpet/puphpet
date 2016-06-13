# Class for installing solr search server
#
class puphpet::solr {

  include ::puphpet::params
  include ::puphpet::supervisord
  include ::solr::params

  $solr = $puphpet::params::hiera['solr']

  $settings = $solr['settings']

  class { 'puphpet::solr::install': }

  $version = $settings['version']
  $url     = 'http://archive.apache.org/dist/lucene/solr'
  $file    = "${version}/solr-${version}.tgz"

  class { 'solr':
    install        => 'source',
    install_source => "${url}/${file}",
    require        => [
      Exec['create solr conf dir'],
      Class['java']
    ],
  }

  if ! defined(Puphpet::Firewall::Port["${settings['port']}"]) {
    puphpet::firewall::port { "${settings['port']}": }
  }

  $destination = $solr::params::install_destination
  $path        = "${destination}/solr-${version}/bin"

  supervisord::program { 'solr':
    command     => "${path}/solr start -p ${settings['port']}",
    priority    => '100',
    user        => 'root',
    autostart   => true,
    autorestart => 'true',
    environment => {
      'PATH' => "/bin:/sbin:/usr/bin:/usr/sbin:${path}"
    },
    require     => Class['solr'],
  }

}
