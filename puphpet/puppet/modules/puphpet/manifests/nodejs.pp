# Installs node.js and npm

class puphpet::nodejs {

  file { '/.puphpet-stuff/node_install.sh':
    ensure  => present,
    owner   => root,
    mode    => 0755,
    content => template("${module_name}/nodejs/install.erb"),
  }
  -> exec { 'install-node':
    command => '/.puphpet-stuff/node_install.sh',
    creates => '/usr/bin/node',
  }

}
