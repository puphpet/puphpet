if $base_values == undef { $base_values = hiera_hash('base', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }
if $apache_values == undef { $apache_values = hiera_hash('apache', false) }
if $nginx_values == undef { $nginx_values = hiera_hash('nginx', false) }

include puphpet::params

#if hash_key_equals($base_values, 'install', 1)
#{
  include base
#}
