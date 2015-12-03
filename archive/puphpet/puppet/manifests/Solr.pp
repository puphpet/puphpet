class puphpet_solr (
  $solr
) {

  include solr::params
  include puphpet::supervisord

  $settings = $solr['settings']

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
