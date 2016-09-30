define puphpet::nginx::locations (
  $locations,
  $ssl,
  $www_root,
  $vhost_key
) {

  include puphpet::nginx::params

  each( $locations ) |$key, $location| {
    if $location['autoindex'] or $location['autoindex'] == 'on' {
      $autoindex = 'on'
    } else {
      $autoindex = 'off'
    }

    if array_true($location, 'internal') and $location['internal'] != 'off' {
      $internal = true
    } else {
      $internal = false
    }

    # remove empty values
    $location_trimmed = merge({
      'fast_cgi_params_extra' => [],
    }, delete_values($location, ''))

    # transforms user-data to expected
    $location_custom_data = merge($location_trimmed, {
      'autoindex' => $autoindex,
      'internal'  => $internal,
    })

    # Takes gui ENV vars: fastcgi_param {ENV_NAME} {VALUE}
    $location_custom_cfg_append = prefix(
      $location_custom_data['fast_cgi_params_extra'],
      'fastcgi_param '
    )

    # separate from $location_custom_data because some values
    # really need to be set to a default.
    # Removes fast_cgi_params_extra because it only exists in gui
    # not puppet-nginx
    $location_no_root = delete(merge({
      'vhost'                      => $vhost_key,
      'ssl'                        => $ssl,
      'location_custom_cfg_append' => $location_custom_cfg_append,
    }, $location_custom_data), 'fast_cgi_params_extra')

    # If www_root was removed with all the trimmings,
    # add it back it
    if ! array_true($location_no_root, 'fastcgi') {
      $location_root_merged = merge({
        'www_root' => $www_root,
      }, $location_no_root)
    } else {
      $location_root_merged = $location_no_root
    }

    # location rewrites
    $location_merged = deep_merge($location_root_merged, {
      'rewrites'  => array_true($location_root_merged, 'rewrites') ? {
        true    => $location_root_merged['rewrites'],
        default => { }
      }
    })

    create_resources(nginx::resource::location, { "${key}" => $location_merged })
  }

}
