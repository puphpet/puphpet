define puphpet::nginx::proxies (
  $proxies
) {

  include ::puphpet::nginx::params

  each( $proxies ) |$key, $proxy| {
    $proxy_redirect = array_true($proxy, 'proxy_redirect') ? {
      true    => $proxy['proxy_redirect'],
      default => undef,
    }
    $proxy_read_timeout = array_true($proxy, 'proxy_read_timeout') ? {
      true    => $proxy['proxy_read_timeout'],
      default => $nginx::config::proxy_read_timeout,
    }
    $proxy_connect_timeout = array_true($proxy, 'proxy_connect_timeout') ? {
      true    => $proxy['proxy_connect_timeout'],
      default => $nginx::config::proxy_connect_timeout,
    }
    $proxy_set_header = array_true($proxy, 'proxy_set_header') ? {
      true    => $proxy['proxy_set_header'],
      default => [],
    }
    $proxy_cache = array_true($proxy, 'proxy_cache') ? {
      true    => $proxy['proxy_cache'],
      default => false,
    }
    $proxy_cache_valid = array_true($proxy, 'proxy_cache_valid') ? {
      true    => $proxy['proxy_cache_valid'],
      default => false,
    }
    $proxy_method = array_true($proxy, 'proxy_method') ? {
      true    => $proxy['proxy_method'],
      default => undef,
    }
    $proxy_set_body = array_true($proxy, 'proxy_set_body') ? {
      true    => $proxy['proxy_set_body'],
      default => undef,
    }

    $merged = merge($proxy, {
      'proxy_redirect'        => $proxy_redirect,
      'proxy_read_timeout'    => $proxy_read_timeout,
      'proxy_connect_timeout' => $proxy_connect_timeout,
      'proxy_set_header'      => $proxy_set_header,
      'proxy_cache'           => $proxy_cache,
      'proxy_cache_valid'     => $proxy_cache_valid,
      'proxy_method'          => $proxy_method,
      'proxy_set_body'        => $proxy_set_body,
    })

    create_resources(nginx::resource::vhost, { "${key}" => $merged })
  }

}
