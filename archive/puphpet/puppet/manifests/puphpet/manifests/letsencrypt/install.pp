# Class for installing Let's Encrypt tool
#
# Generates SSL certs for Apache/Nginx vhosts
#
class puphpet::letsencrypt::install
  inherits puphpet::letsencrypt::params
{

  $letsencrypt = $puphpet::params::hiera['letsencrypt']

  if ! defined(Puphpet::Firewall::Port['80']) {
    puphpet::firewall::port { '80': }
  }

  include puphpet::letsencrypt::certbot
  puphpet::letsencrypt::generate_certs { 'from puphpet::letsencrypt::install': }

}
