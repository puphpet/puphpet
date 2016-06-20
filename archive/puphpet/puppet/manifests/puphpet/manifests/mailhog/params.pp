class puphpet::mailhog::params
 inherits puphpet::params
{

  $user  = 'mailhog'
  $group = 'mailhog'

  $package_name = 'hhvm'
  $service_name = 'hhvm'

  $install_path = '/usr/local/bin/mailhog'

  $filename = $::architecture ? {
    'i386'   => 'MailHog_linux_386',
    'amd64'  => 'MailHog_linux_amd64',
    'x86_64' => 'MailHog_linux_amd64'
  }

  $download_url = "https://github.com/mailhog/MailHog/releases/download/v0.2.0/${filename}"

}
