# == Define: apt::key
#
# The apt::key defined type allows for keys to be added to apt's keyring
# which is used for package validation. This defined type uses the apt_key
# native type to manage keys. This is a simple wrapper around apt_key with
# a few safeguards in place.
#
# === Parameters
#
# [*key*]
#   _default_: +$title+, the title/name of the resource
#
#   Is a GPG key ID or full key fingerprint. This value is validated with
#   a regex enforcing it to only contain valid hexadecimal characters, be
#   precisely 8 or 16 hexadecimal characters long and optionally prefixed
#   with 0x for key IDs, or 40 hexadecimal characters long for key
#   fingerprints.
#
# [*ensure*]
#   _default_: +present+
#
#   The state we want this key in, may be either one of:
#   * +present+
#   * +absent+
#
# [*key_content*]
#   _default_: +undef+
#
#   This parameter can be used to pass in a GPG key as a
#   string in case it cannot be fetched from a remote location
#   and using a file resource is for other reasons inconvenient.
#
# [*key_source*]
#   _default_: +undef+
#
#   This parameter can be used to pass in the location of a GPG
#   key. This URI can take the form of a:
#   * +URL+: ftp, http or https
#   * +path+: absolute path to a file on the target system.
#
# [*key_server*]
#   _default_: +undef+
#
#   The keyserver from where to fetch our GPG key. It can either be a domain
#   name or url. It defaults to
#   undef which results in apt_key's default keyserver being used,
#   currently +keyserver.ubuntu.com+.
#
# [*key_options*]
#   _default_: +undef+
#
#   Additional options to pass on to `apt-key adv --keyserver-options`.
define apt::key (
  $key         = $title,
  $ensure      = present,
  $key_content = undef,
  $key_source  = undef,
  $key_server  = undef,
  $key_options = undef,
) {

  validate_re($key, ['\A(0x)?[0-9a-fA-F]{8}\Z', '\A(0x)?[0-9a-fA-F]{16}\Z', '\A(0x)?[0-9a-fA-F]{40}\Z'])
  validate_re($ensure, ['\Aabsent|present\Z',])

  if $key_content {
    validate_string($key_content)
  }

  if $key_source {
    validate_re($key_source, ['\Ahttps?:\/\/', '\Aftp:\/\/', '\A\/\w+'])
  }

  if $key_server {
    validate_re($key_server,['\A((hkp|http|https):\/\/)?([a-z\d])([a-z\d-]{0,61}\.)+[a-z\d]+(:\d{2,5})?$'])
  }

  if $key_options {
    validate_string($key_options)
  }

  case $ensure {
    present: {
      if defined(Anchor["apt_key ${key} absent"]){
        fail("key with id ${key} already ensured as absent")
      }

      if !defined(Anchor["apt_key ${key} present"]) {
        apt_key { $title:
          ensure            => $ensure,
          id                => $key,
          source            => $key_source,
          content           => $key_content,
          server            => $key_server,
          keyserver_options => $key_options,
        } ->
        anchor { "apt_key ${key} present": }
      }
    }

    absent: {
      if defined(Anchor["apt_key ${key} present"]){
        fail("key with id ${key} already ensured as present")
      }

      if !defined(Anchor["apt_key ${key} absent"]){
        apt_key { $title:
          ensure            => $ensure,
          id                => $key,
          source            => $key_source,
          content           => $key_content,
          server            => $key_server,
          keyserver_options => $key_options,
        } ->
        anchor { "apt_key ${key} absent": }
      }
    }

    default: {
      fail "Invalid 'ensure' value '${ensure}' for apt::key"
    }
  }
}
