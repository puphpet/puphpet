## vhost with proxyPass directive
# NB: Please see the other vhost_*.pp example files for further
# examples.

# Base class. Declares default vhost on port 80 and default ssl
# vhost on port 443 listening on all interfaces and serving
# $apache::docroot
class { 'apache': }

# Most basic vhost with proxy_pass
apache::vhost { 'first.example.com':
  port       => 80,
  docroot    => '/var/www/first',
  proxy_pass => [
    {
      'path' => '/first',
      'url'  => 'http://localhost:8080/first'
    },
  ],
}

# vhost with proxy_pass and parameters
apache::vhost { 'second.example.com':
  port       => 80,
  docroot    => '/var/www/second',
  proxy_pass => [
    {
      'path'   => '/second',
      'url'    => 'http://localhost:8080/second',
      'params' => {
        'retry'   => '0',
        'timeout' => '5'
        }
    },
  ],
}

# vhost with proxy_pass and keywords
apache::vhost { 'third.example.com':
  port       => 80,
  docroot    => '/var/www/third',
  proxy_pass => [
    {
      'path'     => '/third',
      'url'      => 'http://localhost:8080/third',
      'keywords' => ['noquery', 'interpolate']
    },
  ],
}

# vhost with proxy_pass, parameters and keywords
apache::vhost { 'fourth.example.com':
  port       => 80,
  docroot    => '/var/www/fourth',
  proxy_pass => [
    {
      'path'     => '/fourth',
      'url'      => 'http://localhost:8080/fourth',
      'params'   => {
        'retry'   => '0',
        'timeout' => '5'
        },
      'keywords' => ['noquery', 'interpolate']
    },
  ],
}
