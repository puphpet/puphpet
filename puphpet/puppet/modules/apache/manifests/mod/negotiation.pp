class apache::mod::negotiation (
  $force_language_priority = 'Prefer Fallback',
  $language_priority = [ 'en', 'ca', 'cs', 'da', 'de', 'el', 'eo', 'es', 'et',
                        'fr', 'he', 'hr', 'it', 'ja', 'ko', 'ltz', 'nl', 'nn',
                        'no', 'pl', 'pt', 'pt-BR', 'ru', 'sv', 'zh-CN',
                        'zh-TW' ],
) {
  if !is_array($force_language_priority) and !is_string($force_language_priority) {
    fail('force_languague_priority must be a string or array of strings')
  }
  if !is_array($language_priority) and !is_string($language_priority) {
    fail('force_languague_priority must be a string or array of strings')
  }

  ::apache::mod { 'negotiation': }
  # Template uses no variables
  file { 'negotiation.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/negotiation.conf",
    content => template('apache/mod/negotiation.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
