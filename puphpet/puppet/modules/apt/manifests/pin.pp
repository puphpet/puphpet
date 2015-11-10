# pin.pp
# pin a release in apt, useful for unstable repositories

define apt::pin(
  $ensure          = present,
  $explanation     = "${caller_module_name}: ${name}",
  $order           = '',
  $packages        = '*',
  $priority        = 0,
  $release         = '', # a=
  $origin          = '',
  $version         = '',
  $codename        = '', # n=
  $release_version = '', # v=
  $component       = '', # c=
  $originator      = '', # o=
  $label           = ''  # l=
) {
  include apt::params

  $preferences_d = $apt::params::preferences_d

  if $order != '' and !is_integer($order) {
    fail('Only integers are allowed in the apt::pin order param')
  }

  $pin_release_array = [
    $release,
    $codename,
    $release_version,
    $component,
    $originator,
    $label]
  $pin_release = join($pin_release_array, '')

  # Read the manpage 'apt_preferences(5)', especially the chapter
  # 'The Effect of APT Preferences' to understand the following logic
  # and the difference between specific and general form
  if is_array($packages) {
    $packages_string = join($packages, ' ')
  } else {
    $packages_string = $packages
  }

  if $packages_string != '*' { # specific form
    if ( $pin_release != '' and ( $origin != '' or $version != '' )) or
      ( $version != '' and ( $pin_release != '' or $origin != '' )) {
      fail('parameters release, origin, and version are mutually exclusive')
    }
  } else { # general form
    if $version != '' {
      fail('parameter version cannot be used in general form')
    }
    if ( $pin_release != '' and $origin != '' ) {
      fail('parameters release and origin are mutually exclusive')
    }
  }


  # According to man 5 apt_preferences:
  # The files have either no or "pref" as filename extension
  # and only contain alphanumeric, hyphen (-), underscore (_) and period
  # (.) characters. Otherwise APT will print a notice that it has ignored a
  # file, unless that file matches a pattern in the
  # Dir::Ignore-Files-Silently configuration list - in which case it will
  # be silently ignored.
  $file_name = regsubst($title, '[^0-9a-z\-_\.]', '_', 'IG')

  $path = $order ? {
    ''      => "${preferences_d}/${file_name}.pref",
    default => "${preferences_d}/${order}-${file_name}.pref",
  }
  file { "${file_name}.pref":
    ensure  => $ensure,
    path    => $path,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('apt/_header.erb', 'apt/pin.pref.erb'),
  }
}
