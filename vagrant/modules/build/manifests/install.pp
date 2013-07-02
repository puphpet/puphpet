define build::install (
    $folder,
    $buildoptions    = '',
    $make_cmd        = '',
    $rm_build_folder = true
) {

    build::requires { "${name}-requires-build-essential" :
        package => 'build-essential'
    }

    $cwd  = '/usr/local/src'
    $test = '/usr/bin/test'

    $make = $make_cmd ? {
        ''      => 'make && make install',
        default => $make_cmd,
    }

    exec { "config-${name}" :
        cwd     => $folder,
        command => $buildoptions,
        timeout => 120,
        onlyif => "/usr/bin/test ! -e /usr/lib/php5/20100525/xhprof.so",
    }

    exec { "make-install-${name}" :
        cwd     => $folder,
        command => $make,
        path    => '/bin:/sbin:/usr/bin:/usr/sbin',
        timeout => 600,
        require => Exec["config-${name}"],
        onlyif => "/usr/bin/test ! -e /usr/lib/php5/20100525/xhprof.so",
    }
}
