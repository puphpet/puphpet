class puphpet_letsencrypt (
  $letsencrypt,
  $apache,
  $nginx
) {

  if array_true($apache, 'install') {
    include ::puphpet::apache::params
    include ::apache::params

    $service = $::apache::params::service_name
    $before  = Package['httpd']
  }

  if array_true($nginx, 'install') {
    include nginx::params

    $service = 'nginx'
    $before  = Package['nginx']
  }

  vcsrepo { '/opt/letsencrypt':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/letsencrypt/letsencrypt',
    user     => 'root',
  }

  # config file could contain no domains key
  $domains = array_true($letsencrypt, 'domains') ? {
    true    => $letsencrypt['domains'],
    default => { }
  }

  if ! defined(Puphpet::Firewall::Port['80']) {
    puphpet::firewall::port { '80': }
  }

  each( $domains ) |$key, $domain| {
    $cmd_standalone = join([
      '/opt/letsencrypt/letsencrypt-auto',
      '--agree-tos',
      '--renew-by-default',
      '--standalone',
      '--standalone-supported-challenges http-01',
      "--email ${letsencrypt['settings']['email']}",
      'certonly',
    ], ' ')

    $cmd_cron = join([
      '/opt/letsencrypt/letsencrypt-auto',
      '--agree-tos',
      '--renew-by-default',
      "--email ${letsencrypt['settings']['email']}",
      'certonly',
      '-a webroot',
      "--webroot-path=${domain['webroot']}",
    ], ' ')

    $domains_joined = join($domain['hosts'], ' -d ')
    $domains_joined_no_flag = join($domain['hosts'], ' ')

    $cmd_standalone_joined = "${cmd_standalone} -d ${domains_joined}"
    $cmd_cron_joined       = "${cmd_cron} -d ${domains_joined} && service ${service} restart"

    # Generate initial cert before Nginx or Apache are installed
    # If this server already existed, Nginx/Apache may already be installed
    # and using port 80 - standalone cmd will fail,
    # run the cron webroot cmd instead
    exec { "generate ssl cert for ${domain['hosts'][0]}":
      command => "${cmd_standalone_joined} || ${cmd_cron_joined}",
      creates => "/etc/letsencrypt/live/${domain['hosts'][0]}/fullchain.pem",
      group   => 'root',
      user    => 'root',
      path    => [ '/bin', '/sbin/', '/usr/sbin/', '/usr/bin' ],
      require => [
        Vcsrepo['/opt/letsencrypt'],
        Puphpet::Firewall::Port['80'],
      ],
      before => $before,
    }

    cron { "letsencrypt cron for ${domain['hosts'][0]}":
       command  => $cmd_cron_joined,
       minute   => '45',
       hour     => '3',
       weekday  => '1',
       month    => '*',
       monthday => '*',
       user     => 'root',
    }
  }

}
