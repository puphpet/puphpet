class puphpet::server::centos_ius {

  $path = '/.puphpet-stuff/ius.sh'

  puphpet::server::wget { $path:
    source => 'https://setup.ius.io/',
    user   => 'root',
    group  => 'root',
    mode   => '+x'
  }
  -> exec { "${path} && touch /.puphpet-stuff/ius.sh-ran":
    creates => '/.puphpet-stuff/ius.sh-ran',
    timeout => 3600,
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

}
