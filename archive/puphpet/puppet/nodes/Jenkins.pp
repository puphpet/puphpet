if $jenkins_values == undef { $jenkins_values = hiera_hash('jenkins', false) }

include puphpet::params

if hash_key_equals($jenkins_values, 'install', 1)
{
  class { 'jenkins::slave':
    masterurl => $jenkins_values['masterurl'],
    ui_user => $jenkins_values['ui_user'],
    ui_pass => $jenkins_values['ui_pass'],
  }
}
