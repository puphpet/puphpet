if $blackfire_values == undef { $blackfire_values = hiera_hash('blackfire', false) }
if $php_values == undef { $php_values = hiera_hash('php', false) }

if hash_key_equals($blackfire_values, 'install', 1)
  and hash_key_equals($php_values, 'install', 1)
{
  $blackfire_settings = $blackfire_values['settings']

  create_resources('class', {
    'blackfire' => $blackfire_settings
  })
}
