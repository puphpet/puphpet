class puphpet_elasticsearch (
  $elasticsearch
) {

  if ! defined(Puphpet::Firewall::Port["9200"]) {
    puphpet::firewall::port { "9200": }
  }

  $settings = $elasticsearch['settings']
  $version  = $elasticsearch['settings']['version']

  $url_base = 'https://download.elasticsearch.org/elasticsearch/elasticsearch'

  case $::osfamily {
    'debian': {
      $url = "${url_base}/elasticsearch-${version}.deb"
    }
    'redhat': {
      $url = "${url_base}/elasticsearch-${version}.noarch.rpm"
    }
    default: {
      fail('Unrecognized operating system for Elastic Search')
    }
  }

  if ! defined(Class['java']) and $settings['java_install'] {
    class { 'java':
      distribution => 'jre',
    }
  }

  $merged = delete(merge($settings, {
    'java_install' => false,
    'package_url'  => $url,
    require        => Class['puphpet::firewall::post'],
  }), 'version')

  create_resources('class', { 'elasticsearch' => $merged })

  # config file could contain no instance keys
  $instances = array_true($elasticsearch, 'instances') ? {
    true    => $elasticsearch['instances'],
    default => { }
  }

  each( $instances ) |$key, $instance| {
    $name = $instance['name']

    create_resources( elasticsearch::instance, { "${name}" => $instance })
  }

}
