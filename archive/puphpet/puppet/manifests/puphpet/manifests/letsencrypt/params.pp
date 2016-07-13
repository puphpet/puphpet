class puphpet::letsencrypt::params
  inherits ::puphpet::params
{

  $certbot     = '/usr/bin/certbot-auto'
  $certbot_url = 'https://dl.eff.org/certbot-auto'

  # config file could contain no domains key
  $domains = array_true($puphpet::params::hiera['letsencrypt'], 'domains') ? {
    true    => $puphpet::params::hiera['letsencrypt']['domains'],
    default => { }
  }

}
