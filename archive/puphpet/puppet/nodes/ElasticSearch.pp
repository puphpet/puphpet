if $elasticsearch_values == undef { $elasticsearch_values = hiera_hash('elastic_search', false) }

include puphpet::params

if hash_key_equals($elasticsearch_values, 'install', 1) {
  $es_version = $elasticsearch_values['settings']['version']

  case $::osfamily {
    'debian': { $elasticsearch_package_url = "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${es_version}.deb" }
    'redhat': { $elasticsearch_package_url = "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${es_version}.noarch.rpm" }
    default:  { fail('Unrecognized operating system for Elastic Search') }
  }

  if ! defined(Class['java']) and $elasticsearch_values['settings']['java_install'] {
    class { 'java':
      distribution => 'jre',
    }
  }

  $elasticsearch_settings = delete(merge($elasticsearch_values['settings'], {
    'java_install' => false,
    'package_url'  => $elasticsearch_package_url,
    require        => Class['my_fw::post'],
  }), 'version')

  create_resources('class', { 'elasticsearch' => $elasticsearch_settings })
}
