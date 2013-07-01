define php::custom::xhprof (
  $output_dir = '/home/vagrant/xhprof'
) {
    if !defined(File[$output_dir]) {
      file { $output_dir:
        ensure => directory,
        owner  => 'www-data'
      }
    }

    git::repo { 'xhprof':
      path   => '/var/www/xhprof',
      source => 'https://github.com/facebook/xhprof.git'
    }

    exec { 'chown-xhprof-output':
      command => "chown www-data ${output_dir} -R",
      path    => '/bin',
      require => [
        File[$output_dir],
        Git::Repo['xhprof']
      ],
      refreshonly => true
    }

    exec { 'add-xhprof-output-dir-to-ini':
      command => "echo 'xhprof.output_dir=\"${output_dir}\"' >> ${php::params::config_dir}/conf.d/pecl-xhprof.ini",
      path    => '/bin',
      require => Exec['pecl-xhprof-ini-so-include'],
      onlyif  => "/usr/bin/test ! $(/bin/grep -c 'xhprof.output_dir=\"${output_dir}\"' ${php::params::config_dir}/conf.d/pecl-xhprof.ini) -ne 0"
    }
}
