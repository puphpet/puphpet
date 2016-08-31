node default {
  include composer

  composer::project {'silex':
    project_name   => 'fabpot/silex-skeleton',
    target_dir     => '/tmp/silex',
  }
}
