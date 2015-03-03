if $drush_values == undef { $drush_values = hiera_hash('drush', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $hhvm_values == undef { $hhvm_values = hiera_hash('hhvm', false) }

include puphpet::params

if hash_key_equals($drush_values, 'install', 1) {
  # Requires either PHP or HHVM, and Composer
  if $drush_values['version'] != undef
    and (hash_key_equals($php_values, 'install', 1)
          or hash_key_equals($hhvm_values, 'install', 1))
    and (hash_key_equals($php_values, 'composer', 1)
          or hash_key_equals($hhvm_values, 'composer', 1))
  {
    class { 'puphpet::php::drush':
      version => $drush_values['version']
    }
  }
}
