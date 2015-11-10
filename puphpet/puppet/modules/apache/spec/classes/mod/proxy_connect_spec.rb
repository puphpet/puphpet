require 'spec_helper'

describe 'apache::mod::proxy_connect', :type => :class do
  let :pre_condition do
    [
      'include apache',
      'include apache::mod::proxy',
    ]
  end
  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily        => 'Debian',
        :concat_basedir  => '/dne',
        :operatingsystem => 'Debian',
        :id              => 'root',
        :kernel          => 'Linux',
        :path            => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    context 'with Apache version < 2.4' do
      let :facts do
        super().merge({
          :operatingsystemrelease => '7.0',
          :lsbdistcodename        => 'wheezy',
        })
      end
      let :params do
        {
          :apache_version => '2.2',
        }
      end
      it { is_expected.not_to contain_apache__mod('proxy_connect') }
    end
    context 'with Apache version >= 2.4' do
      let :facts do
        super().merge({
          :operatingsystemrelease => '8.0',
          :lsbdistcodename        => 'jessie',
        })
      end
      let :params do
        {
          :apache_version => '2.4',
        }
      end
      it { is_expected.to contain_apache__mod('proxy_connect') }
    end
  end
end
