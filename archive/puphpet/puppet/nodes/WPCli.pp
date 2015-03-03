if $wpcli_values == undef { $wpcli_values = hiera_hash('wpcli', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }

include puphpet::params

if hash_key_equals($wpcli_values, 'install', 1) {
  if $wpcli_values['version'] != undef
    and (hash_key_equals($php_values, 'install', 1)
          or hash_key_equals($hhvm_values, 'install', 1))
    and (hash_key_equals($php_values, 'composer', 1)
          or hash_key_equals($hhvm_values, 'composer', 1))
  {
    class { 'puphpet::php::wordpress::wpcli' :
      version => $wpcli_values['version']
    }
  }
}
