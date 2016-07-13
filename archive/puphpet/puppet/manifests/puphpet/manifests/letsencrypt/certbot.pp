# == Define Resource Type: puphpet::letsencrypt::certbot
#
class puphpet::letsencrypt::certbot {

  include ::puphpet::letsencrypt::params

  puphpet::server::wget { $puphpet::letsencrypt::params::certbot:
    source => $puphpet::letsencrypt::params::certbot_url,
    user   => 'root',
    group  => 'root',
    mode   => 'a+x'
  }

}
