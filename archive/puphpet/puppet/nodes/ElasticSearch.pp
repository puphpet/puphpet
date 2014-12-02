if $elasticsearch_values == undef { $elasticsearch_values = hiera_hash('elastic_search', false) }

include puphpet::params

if hash_key_equals($elasticsearch_values, 'install', 1) {
  case $::osfamily {
    'debian': { $elasticsearch_package_url = 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.2.1.deb' }
    'redhat': { $elasticsearch_package_url = 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.2.1.noarch.rpm' }
    default:  { fail('Unrecognized operating system for Elastic Search') }
  }

  $elasticsearch_settings = merge($elasticsearch_values['settings'], {
    'package_url' => $elasticsearch_package_url,
    require       => Class['my_fw::post'],
  })

  create_resources('class', { 'elasticsearch' => $elasticsearch_settings })
}
