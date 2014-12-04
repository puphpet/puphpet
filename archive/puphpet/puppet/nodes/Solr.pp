if $solr_values == undef { $solr_values = hiera_hash('solr', false) }

include solr::params

if hash_key_equals($solr_values, 'install', 1) {
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

  class { 'solr':
    install        => 'source',
    install_source => "http://archive.apache.org/dist/lucene/solr/${solr_values['settings']['version']}/solr-${solr_values['settings']['version']}.tgz",
    require        => [
      Exec['create solr conf dir'],
      Class['java']
    ],
  }

  if ! defined(Firewall["100 tcp/${solr_values['settings']['port']}"]) {
    firewall { "100 tcp/${solr_values['port']}":
      port   => $solr_values['port'],
      proto  => tcp,
      action => 'accept',
    }
  }

  $solr_path = "${solr::params::install_destination}/solr-${solr_values['settings']['version']}/bin"

  supervisord::program { 'solr':
    command     => "${solr_path}/solr start -p ${solr_values['settings']['port']}",
    priority    => '100',
    user        => 'root',
    autostart   => true,
    autorestart => 'true',
    environment => {
      'PATH' => "/bin:/sbin:/usr/bin:/usr/sbin:${solr_path}"
    },
    require => Class['solr'],
  }
}
