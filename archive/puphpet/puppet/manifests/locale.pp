class puphpet_locale (
  $locales
) {

  $settings = $locales['settings']

  if $::osfamily == 'debian' {
    $default_locale = array_true($settings, 'default_locale') ? {
      true    => $settings['default_locale'],
      default => ''
    }

    $user_locale = array_true($settings, 'locales') ? {
      true    => $settings['locales'],
      default => ['en_US.UTF-8', 'en_GB.UTF-8']
    }

    $merged = delete(merge($settings, {
      'default_locale' => $default_locale,
      'locales'        => suffix($user_locale, ' UTF-8'),
    }), 'timezone')

    create_resources('class', { 'locales' => $merged })
  }

  $timezone = array_true($settings, 'timezone') ? {
    true    => $settings['timezone'],
    default => 'UTC'
  }

  class { 'timezone':
    timezone => $timezone,
  }

}
