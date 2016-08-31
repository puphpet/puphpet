#  => ' Class: yum::repo::mysql_community'
#
# This class installs the mysql_community repos
#
class yum::repo::mysql_community(
    $enabled_version  = '5.6'
) {
    yum::managed_yumrepo { 'mysql-connectors-community':
        descr         => 'MySQL Connectors Community',
        baseurl       => 'http://repo.mysql.com/yum/mysql-connectors-community/el/6/$basearch/',
        enabled       => '1',
        gpgcheck      => '1',
        gpgkey        => 'file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql',
        gpgkey_source => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-mysql'

    }

    yum::managed_yumrepo { 'mysql-tools-community':
        descr         => 'MySQL Tools Community',
        baseurl       => 'http://repo.mysql.com/yum/mysql-tools-community/el/6/$basearch/',
        enabled       => '1',
        gpgcheck      => '1',
        gpgkey        => 'file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql',
        gpgkey_source => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-mysql'
    }

    # Enable to use MySQL 5.5
    yum::managed_yumrepo { 'mysql55-community':
        descr         => 'MySQL 5.5 Community Server',
        baseurl       => 'http://repo.mysql.com/yum/mysql-5.5-community/el/6/$basearch/',
        enabled       => $enabled_version ? { '5.5' => '1', default => '0' },
        gpgcheck      => '1',
        gpgkey        => 'file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql',
        gpgkey_source => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-mysql'
    }

    # Enable to use MySQL 5.6
    yum::managed_yumrepo { 'mysql56-community':
        descr         => 'MySQL 5.6 Community Server',
        baseurl       => 'http://repo.mysql.com/yum/mysql-5.6-community/el/6/$basearch/',
        enabled       => $enabled_version ? { '5.6' => '1', default => '0' },
        gpgcheck      => '1',
        gpgkey        => 'file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql',
        gpgkey_source => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-mysql'
    }

    # Note: MySQL 5.7 is currently in development. For use at your own risk.
    # Please read with sub pages: https://dev.mysql.com/doc/relnotes/mysql/5.7/en/
    yum::managed_yumrepo { 'mysql57-community-dmr':
        descr         => 'MySQL 5.7 Community Server Development Milestone Release',
        baseurl       => 'http://repo.mysql.com/yum/mysql-5.7-community/el/6/$basearch/',
        enabled       => $enabled_version ? { '5.7' => '1', default => '0' },
        gpgcheck      => '1',
        gpgkey        => 'file:/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql',
        gpgkey_source => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-mysql'
    }
}
