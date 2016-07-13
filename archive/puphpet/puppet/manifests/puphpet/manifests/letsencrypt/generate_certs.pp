# == Define Resource Type: puphpet::letsencrypt::generate_certs
#
# Generates SSL certificates using Let's Encrypt certbot-auto tool
#
define puphpet::letsencrypt::generate_certs (
  $domains = $::puphpet::letsencrypt::params::domains
){

  include puphpet::letsencrypt::params

  $cmd_base = join([
    $puphpet::letsencrypt::params::certbot,
    'certonly',
    '--agree-tos',
    '--keep-until-expiring',
    '--standalone',
    '--standalone-supported-challenges http-01',
    '--noninteractive',
    "--email '${puphpet::params::hiera['letsencrypt']['settings']['email']}'",
    "--pre-hook 'service ${webserver_service} stop || true'",
    "--post-hook 'service ${webserver_service} start || true'",
  ], ' ')

  each( $domains ) |$key, $domain| {
    $hosts = join($domain['hosts'], ' -d ')

    $cmd_final = "${cmd_base} -d ${hosts}"

    $hour   = seeded_rand(23, $::fqdn)
    $minute = seeded_rand(59, $::fqdn)

    exec { "generate ssl cert for ${domain['hosts'][0]}":
      command => $cmd_final,
      creates => "/etc/letsencrypt/live/${domain['hosts'][0]}/fullchain.pem",
      group   => 'root',
      user    => 'root',
      path    => [ '/bin', '/sbin/', '/usr/sbin/', '/usr/bin' ],
      require => [
        Class['Puphpet::Letsencrypt::Certbot'],
        Puphpet::Firewall::Port['80'],
      ],
    }

    cron { "letsencrypt cron for ${domain['hosts'][0]}":
       command  => $cmd_final,
       minute   => "${minute}",
       hour     => "${hour}",
       weekday  => '*',
       month    => '*',
       monthday => '*',
       user     => 'root',
    }
  }

}
