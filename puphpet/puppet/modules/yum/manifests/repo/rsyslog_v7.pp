# = Class: yum::repo::rsyslog_v7
#
# This class installs the rsyslog v7 repo
#
class yum::repo::rsyslog_v7 (
  $mirror_url = undef
) {

  if $mirror_url {
    validate_re(
      $mirror_url,
      '^(?:https?|ftp):\/\/[\da-zA-Z-][\da-zA-Z\.-]*\.[a-zA-Z]{2,6}\.?(?:\/[\w~-]*)*$',
      '$mirror must be a Clean URL with no query-string, a fully-qualified hostname and no trailing slash.'
    )
  }

  $real_mirror_url = $mirror_url ? {
    default => $mirror_url,
    undef   => 'http://rpms.adiscon.com/v7-stable/epel-$releasever/$basearch'
  }

  yum::managed_yumrepo { 'rsyslog_v7':
    descr          => 'Adiscon CentOS-$releasever - $basearch',
    baseurl        => $real_mirror_url,
    enabled        => 1,
    gpgcheck       => 1,
    gpgkey         => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Adiscon",
    gpgkey_source  => "puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-Adiscon",
    priority       => 10,
    failovermethod => 'priority',
  }

}
