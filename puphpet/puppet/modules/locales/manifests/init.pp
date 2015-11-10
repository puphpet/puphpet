# Class: locales
#
# This module manages locales
#
# Parameters:
#   [*locales*]
#     Name of locales to generate
#     Default: [ 'en_US.UTF-8 UTF-8', 'de_DE.UTF-8 UTF-8', ]
#
#   [*ensure*]
#     Ensure if present or absent.
#     Default: present
#
#   [*default_locale*]
#     The value of the LANG environment variable. Used by the locale system as
#     default for other LC_* variables that have not been set explicitly. When
#     setting this make sure the desired locale exists by specifying it in the
#     *locales* parameter.
#     Example: default_locale => 'en_GB.UTF-8'
#     Default: undef
#
#   [*lc_ctype*]
#     Character classification and case conversion. How characters are
#     classified as letters, numbers etc. This determines things like how
#     characters are converted between upper and lower case.
#     Default: undef
#
#   [*lc_collate*]
#     Collation order. How strings (file names...) are alphabetically sorted.
#     Using the "C" or "POSIX" locale here results in a strcmp()-like sort
#     order, which may be preferable to language-specific locales.
#     Default: undef
#
#   [*lc_time*]
#     Date and time formats. How your time and date are formatted. Use for
#     example "en_DK.UTF-8" to get a 24-hour-clock in some programs.
#     Default: undef
#
#   [*lc_numeric*]
#     Non-monetary numeric formats. How you format your numbers. For example,
#     in many countries a period (.) is used as a decimal separator, while
#     others use a comma (,).
#     Default: undef
#
#   [*lc_monetary*]
#     Monetary formats. What currency you use, its name, and its symbol.
#     Default: undef
#
#   [*lc_messages*]
#     Formats of informative and diagnostic messages and interactive responses.
#     Default: undef
#
#   [*lc_paper*]
#     Paper size.
#     Default: undef
#
#   [*lc_name*]
#     Name formats. How names are represented (surname first or last, etc.).
#     Default: undef
#
#   [*lc_address*]
#     Address formats and location information. How addresses are formatted
#     (country first or last, where zip code goes etc.).
#     Default: undef
#
#   [*lc_telephone*]
#     Telephone number formats.
#     Default: undef
#
#   [*lc_measurement*]
#     Measurement units (Metric or Other). What units of measurement are used
#     (feet, meters, pounds, kilos etc.).
#     Default: undef
#
#   [*lc_identification*]
#     Metadata about the locale information.
#     Default: undef
#
#   [*lc_all*]
#     Primary Language
#     Default: undef
#
#   [*autoupgrade*]
#     Upgrade package automatically, if there is a newer version.
#     Default: false
#
#   [*package*]
#     Name of the package.
#     Only set this, if your platform is not supported or you know, what you're doing.
#     Default: auto-set, platform specific
#
#   [*config_file*]
#     Main configuration file.
#     Only set this, if your platform is not supported or you know, what you're doing.
#     Default: auto-set, platform specific
#
#   [*locale_gen_command*]
#     Command to generate locales.
#     Only set this, if your platform is not supported or you know, what you're doing.
#     Default: auto-set, platform specific
#
# Actions:
#   Installs locales package, generates specified locales and sets
#   locale-related environment variables in the appropriate system-wide
#   configuration file.
#
# Requires:
#   Nothing
#
# Sample Usage:
#   class { 'locales':
#     locales        => [ 'en_US.UTF-8 UTF-8', 'de_DE.UTF-8 UTF-8', 'en_GB.UTF-8 UTF-8', ],
#     default_locale => 'en_GB.UTF-8',
#     lc_time        => 'en_DK.UTF-8'
#   }
#
# [Remember: No empty lines between comments and class definition]
class locales (
  $locales           = [ 'en_US.UTF-8 UTF-8', 'de_DE.UTF-8 UTF-8', ],
  $ensure            = 'present',
  $default_locale    = undef,
  $language  = undef,
  $lc_ctype          = $locales::params::lc_ctype,
  $lc_collate        = $locales::params::lc_collate,
  $lc_time           = $locales::params::lc_time,
  $lc_numeric        = $locales::params::lc_numeric,
  $lc_monetary       = $locales::params::lc_monetary,
  $lc_messages       = $locales::params::lc_messages,
  $lc_paper          = $locales::params::lc_paper,
  $lc_name           = $locales::params::lc_name,
  $lc_address        = $locales::params::lc_address,
  $lc_telephone      = $locales::params::lc_telephone,
  $lc_measurement    = $locales::params::lc_measurement,
  $lc_identification = $locales::params::lc_identification,
  $lc_all            = $locales::params::lc_all,
  $autoupgrade       = false,
  $package           = $locales::params::package,
  $config_file       = $locales::params::config_file,
  $locale_gen_cmd    = $locales::params::locale_gen_cmd,
  $default_file      = $locales::params::default_file,
  $update_locale_pkg = $locales::params::update_locale_pkg,
  $update_locale_cmd = $locales::params::update_locale_cmd,
  $supported_locales = $locales::params::supported_locales # ALL locales support
) inherits locales::params {

  case $ensure {
    /(present)/: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }
      # ALL locales support
      if $locales == ['ALL'] {
        $config_ensure = 'link'
      } else {
        $config_ensure = 'file'
      }
    }
    /(absent)/: {
      $package_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  package { $package:
    ensure => $package_ensure,
  }

  if $update_locale_pkg != false {
    package { $update_locale_pkg:
      ensure => $package_ensure,
    }

    $update_locale_require = Package[$update_locale_pkg]
  } else {
    $update_locale_require = Package[$package]
  }
  # ALL locales support
  file { $config_file:
    ensure  => $config_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$package],
    notify  => Exec['locale-gen'],
  }
  # ALL locales support
  if $locales == ['ALL'] {
    File[$config_file] {
      target => $supported_locales,
    }
  } else {
    File[$config_file] {
      content => template('locales/locale.gen.erb'),
    }
  }

  file { $default_file:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/locale.erb"),
    require => $update_locale_require,
    notify  => Exec['update-locale'],
  }

  exec { 'locale-gen':
    command     => $locale_gen_cmd,
    refreshonly => true,
    path        => ['/usr/local/bin', '/usr/bin', '/bin', '/usr/local/sbin', '/usr/sbin', '/sbin'],
    require     => Package[$package],
    #locale-gen with all locales may take a very long time
    timeout     => 900,
  }

  exec { 'update-locale':
    command     => $update_locale_cmd,
    refreshonly => true,
    path        => ['/usr/local/bin', '/usr/bin', '/bin', '/usr/local/sbin', '/usr/sbin', '/sbin'],
    require     => $update_locale_require,
  }
}
