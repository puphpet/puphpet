# = Class: yum::repo::remi_php56
#
# This class installs the remi-php56 repo
#
class yum::repo::remi_php56 {
  yum::managed_yumrepo { 'remi-php56':
    descr          => 'Les RPM de remi pour Enterpise Linux $releasever - $basearch - PHP 5.6',
    mirrorlist     => 'http://rpms.famillecollet.com/enterprise/$releasever/php56/mirror',
    enabled        => 1,
    gpgcheck       => 1,
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi',
    gpgkey_source  => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-remi',
    priority       => 1,
  }
}
