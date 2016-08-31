ini_setting { 'sample setting':
  ensure  => present,
  path    => '/tmp/foo.ini',
  section => 'foo',
  setting => 'foosetting',
  value   => 'FOO!',
}

ini_setting { 'sample setting2':
  ensure            => present,
  path              => '/tmp/foo.ini',
  section           => 'bar',
  setting           => 'barsetting',
  value             => 'BAR!',
  key_val_separator => '=',
  require           => Ini_setting['sample setting'],
}

ini_setting { 'sample setting3':
  ensure  => absent,
  path    => '/tmp/foo.ini',
  section => 'bar',
  setting => 'bazsetting',
  require => Ini_setting['sample setting2'],
}
