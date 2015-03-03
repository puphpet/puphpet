if $elasticsearch_values == undef { $elasticsearch_values = hiera_hash('elastic_search', false) }

include puphpet::params

if hash_key_equals($elasticsearch_values, 'install', 1) {
  $es_settings = $elasticsearch_values['settings']
  $es_version = $elasticsearch_values['settings']['version']

  $url_base = 'https://download.elasticsearch.org/elasticsearch/elasticsearch'

  case $::osfamily {
    'debian': {
      $es_package_url = "${url_base}/elasticsearch-${es_version}.deb"
    }
    'redhat': {
      $es_package_url = "${url_base}/elasticsearch-${es_version}.noarch.rpm"
    }
    default:  {
      fail('Unrecognized operating system for Elastic Search')
    }
  }

  if ! defined(Class['java'])
    and $es_settings['java_install']
  {
    class { 'java':
      distribution => 'jre',
    }
  }

  $es_settings_merged = delete(merge($es_settings, {
    'java_install' => false,
    'package_url'  => $es_package_url,
    require        => Class['puphpet::firewall::post'],
  }), 'version')

  create_resources('class', { 'elasticsearch' => $es_settings_merged })
}
