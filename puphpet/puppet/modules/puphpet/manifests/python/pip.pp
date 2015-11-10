class puphpet::python::pip {

  Exec { path => [ '/usr/bin/', '/usr/local/bin', '/bin', '/usr/local/sbin', '/usr/sbin', '/sbin' ] }

  $url = 'https://bootstrap.pypa.io/ez_setup.py'
  $download_location = '/.puphpet-stuff/ez_setup.py'

  exec { "Download and install ez_setup":
    creates => $download_location,
    command => "wget ${url} -O ${download_location} && \
                python ${download_location}",
    timeout => 30,
    path    => '/usr/bin'
  }
  -> exec { 'easy_install pip':
    unless => 'which pip',
  }

  if $::osfamily == 'RedHat' {
    exec { 'rhel pip_provider_name_fix':
      command   => 'alternatives --install /usr/bin/pip-python pip-python /usr/bin/pip 1',
      subscribe => Exec['easy_install pip'],
      unless    => 'which pip-python',
    }
  }

}
