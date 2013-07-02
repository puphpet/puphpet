define php::ini::removeblock (
    $block_name,
    $ini_file
) {
  $left_side_regex = 'perl -pi -w -e "s/^(\[?)'
  $right_side_regex = '(\]?)(.+\n)//"'
  $cmd = "${left_side_regex}${block_name}${right_side_regex}"

  exec { "${cmd} ${ini_file}":
    path    => '/usr/bin/',
    require => Package['php']
  }
}
