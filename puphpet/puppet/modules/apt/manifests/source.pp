# source.pp
# add an apt source

define apt::source(
  $comment           = $name,
  $ensure            = present,
  $location          = '',
  $release           = 'UNDEF',
  $repos             = 'main',
  $include_src       = true,
  $include_deb       = true,
  $required_packages = false,
  $key               = undef,
  $key_server        = 'keyserver.ubuntu.com',
  $key_content       = undef,
  $key_source        = undef,
  $pin               = false,
  $architecture      = undef,
  $trusted_source    = false,
) {

  include apt::params
  include apt::update

  validate_string($architecture)
  validate_bool($trusted_source)

  $sources_list_d = $apt::params::sources_list_d
  $provider       = $apt::params::provider

  if $release == 'UNDEF' {
    if $::lsbdistcodename == undef {
      fail('lsbdistcodename fact not available: release parameter required')
    } else {
      $release_real = $::lsbdistcodename
    }
  } else {
    $release_real = $release
  }

  file { "${name}.list":
    ensure  => $ensure,
    path    => "${sources_list_d}/${name}.list",
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('apt/_header.erb', 'apt/source.list.erb'),
    notify  => Exec['apt_update'],
  }


  if ($pin != false) {
    # Get the host portion out of the url so we can pin to origin
    $url_split = split($location, '/')
    $host      = $url_split[2]

    apt::pin { $name:
      ensure   => $ensure,
      priority => $pin,
      before   => File["${name}.list"],
      origin   => $host,
    }
  }

  if ($required_packages != false) and ($ensure == 'present') {
    exec { "Required packages: '${required_packages}' for ${name}":
      command     => "${provider} -y install ${required_packages}",
      logoutput   => 'on_failure',
      refreshonly => true,
      tries       => 3,
      try_sleep   => 1,
      subscribe   => File["${name}.list"],
      before      => Exec['apt_update'],
    }
  }

  # We do not want to remove keys when the source is absent.
  if $key and ($ensure == 'present') {
    apt::key { "Add key: ${key} from Apt::Source ${title}":
      ensure      => present,
      key         => $key,
      key_server  => $key_server,
      key_content => $key_content,
      key_source  => $key_source,
      before      => File["${name}.list"],
    }
  }

  # Need anchor to provide containment for dependencies.
  anchor { "apt::source::${name}":
    require => Class['apt::update'],
  }
}
