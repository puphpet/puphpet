if $solr_values == undef { $solr_values = hiera_hash('solr', false) }

include solr::params

if hash_key_equals($solr_values, 'install', 1) {
  $solr_settings = $solr_values['settings']

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

  $solr_version = $solr_settings['version']
  $solr_source_url = 'http://archive.apache.org/dist/lucene/solr'
  $solr_source_file = "${solr_version}/solr-${solr_version}.tgz"

  class { 'solr':
    install        => 'source',
    install_source => "${solr_source_url}/${solr_source_file}",
    require        => [
      Exec['create solr conf dir'],
      Class['java']
    ],
  }

  if ! defined(Puphpet::Firewall::Port[$solr_settings['port']]) {
    puphpet::firewall::port { $solr_settings['port']: }
  }

  $solr_destination = $solr::params::install_destination

  $solr_path = "${solr_destination}/solr-${solr_version}/bin"

  supervisord::program { 'solr':
    command     => "${solr_path}/solr start -p ${solr_settings['port']}",
    priority    => '100',
    user        => 'root',
    autostart   => true,
    autorestart => 'true',
    environment => {
      'PATH' => "/bin:/sbin:/usr/bin:/usr/sbin:${solr_path}"
    },
    require     => Class['solr'],
  }
}
