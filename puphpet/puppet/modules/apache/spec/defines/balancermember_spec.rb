require 'spec_helper'

describe 'apache::balancermember', :type => :define do
  let :pre_condition do
    'include apache
    apache::balancer {"balancer":}
    apache::balancer {"balancer-external":}
    apache::balancermember {"http://127.0.0.1:8080-external": url => "http://127.0.0.1:8080/", balancer_cluster => "balancer-external"}
    '
  end
  let :title do
    'http://127.0.0.1:8080/'
  end
  let :params do
    {
      :options          => [],
      :url              => 'http://127.0.0.1:8080/',
      :balancer_cluster => 'balancer-internal'
    }
  end
  let :facts do
    {
      :osfamily               => 'Debian',
      :operatingsystem        => 'Debian',
      :operatingsystemrelease => '6',
      :lsbdistcodename        => 'squeeze',
      :id                     => 'root',
      :concat_basedir         => '/dne',
      :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      :kernel                 => 'Linux',
      :is_pe                  => false,
    }
  end
  describe "allows multiple balancermembers with the same url" do
    it { should contain_concat__fragment('BalancerMember http://127.0.0.1:8080/') }
  end
end
