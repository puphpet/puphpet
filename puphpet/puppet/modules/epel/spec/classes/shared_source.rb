require 'spec_helper'

shared_context :epel_source do
  it do
    should contain_yumrepo('epel-source').with({
      'proxy'          => 'absent',
      'failovermethod' => 'priority',
      'enabled'        => '0',
      'gpgcheck'       => '1',
    })
  end
end

shared_examples_for :epel_source_7 do
  include_context :epel_source

  it do
    should contain_yumrepo('epel-source').with({
      'mirrorlist'     => "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-source-7&arch=$basearch",
      'gpgkey'         => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7",
      'descr'          => "Extra Packages for Enterprise Linux 7 - $basearch - Source",
    })
  end
end

shared_examples_for :epel_source_6 do
  include_context :epel_source

  it do
    should contain_yumrepo('epel-source').with({
      'mirrorlist'     => "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-source-6&arch=$basearch",
      'gpgkey'         => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6",
      'descr'          => "Extra Packages for Enterprise Linux 6 - $basearch - Source",
    })
  end
end

shared_examples_for :epel_source_5 do
  include_context :epel_source

  it do
    should contain_yumrepo('epel-source').with({
      'mirrorlist'     => "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-source-5&arch=$basearch",
      'gpgkey'         => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-5",
      'descr'          => "Extra Packages for Enterprise Linux 5 - $basearch - Source",
    })
  end
end
