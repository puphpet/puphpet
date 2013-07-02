define apache::ports () {
    $port = $name

    file_line { "port-${port}" :
        ensure  => present,
        line    => "Listen ${port}",
        path    => "${apache::config_dir}/ports.conf",
        require => Package['apache'],
        notify  => $apache::manage_service_autorestart,
    }
}
