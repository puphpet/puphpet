require 'spec_helper'
describe 'apt::ppa', :type => :define do

  describe 'defaults' do
    let :pre_condition do
      'class { "apt": }'
    end
    let :facts do
      {
        :lsbdistrelease  => '11.04',
        :lsbdistcodename => 'natty',
        :operatingsystem => 'Ubuntu',
        :osfamily        => 'Debian',
        :lsbdistid       => 'Ubuntu',
      }
    end

    let(:title) { 'ppa:needs/such.substitution/wow' }
    it { is_expected.to contain_package('python-software-properties') }
    it { is_expected.to contain_exec('add-apt-repository-ppa:needs/such.substitution/wow').that_notifies('Exec[apt_update]').with({
      'environment' => [],
      'command'     => '/usr/bin/add-apt-repository -y ppa:needs/such.substitution/wow',
      'unless'      => '/usr/bin/test -s /etc/apt/sources.list.d/needs-such_substitution-wow-natty.list',
      'user'        => 'root',
      'logoutput'   => 'on_failure',
    })
    }

    it { is_expected.to contain_file('/etc/apt/sources.list.d/needs-such_substitution-wow-natty.list').that_requires('Exec[add-apt-repository-ppa:needs/such.substitution/wow]').with({
      'ensure' => 'file',
    })
    }
  end

  describe 'package_name => software-properties-common' do
    let :pre_condition do
      'class { "apt": }'
    end
    let :params do
      {
        :package_name => 'software-properties-common'
      }
    end
    let :facts do
      {
        :lsbdistrelease  => '11.04',
        :lsbdistcodename => 'natty',
        :operatingsystem => 'Ubuntu',
        :osfamily        => 'Debian',
        :lsbdistid       => 'Ubuntu',
      }
    end

    let(:title) { 'ppa:needs/such.substitution/wow' }
    it { is_expected.to contain_package('software-properties-common') }
    it { is_expected.to contain_exec('add-apt-repository-ppa:needs/such.substitution/wow').that_notifies('Exec[apt_update]').with({
      'environment' => [],
      'command'     => '/usr/bin/add-apt-repository -y ppa:needs/such.substitution/wow',
      'unless'      => '/usr/bin/test -s /etc/apt/sources.list.d/needs-such_substitution-wow-natty.list',
      'user'        => 'root',
      'logoutput'   => 'on_failure',
    })
    }

    it { is_expected.to contain_file('/etc/apt/sources.list.d/needs-such_substitution-wow-natty.list').that_requires('Exec[add-apt-repository-ppa:needs/such.substitution/wow]').with({
      'ensure' => 'file',
    })
    }
  end

  describe 'package_manage => false' do
    let :pre_condition do
      'class { "apt": }'
    end
    let :facts do
      {
        :lsbdistrelease  => '11.04',
        :lsbdistcodename => 'natty',
        :operatingsystem => 'Ubuntu',
        :osfamily        => 'Debian',
        :lsbdistid       => 'Ubuntu',
      }
    end
    let :params do
      {
        :package_manage => false,
      }
    end

    let(:title) { 'ppa:needs/such.substitution/wow' }
    it { is_expected.to_not contain_package('python-software-properties') }
    it { is_expected.to contain_exec('add-apt-repository-ppa:needs/such.substitution/wow').that_notifies('Exec[apt_update]').with({
      'environment' => [],
      'command'     => '/usr/bin/add-apt-repository -y ppa:needs/such.substitution/wow',
      'unless'      => '/usr/bin/test -s /etc/apt/sources.list.d/needs-such_substitution-wow-natty.list',
      'user'        => 'root',
      'logoutput'   => 'on_failure',
    })
    }

    it { is_expected.to contain_file('/etc/apt/sources.list.d/needs-such_substitution-wow-natty.list').that_requires('Exec[add-apt-repository-ppa:needs/such.substitution/wow]').with({
      'ensure' => 'file',
    })
    }
  end

  describe 'apt included, no proxy' do
    let :pre_condition do
      'class { "apt": }'
    end
    let :facts do
      {
        :lsbdistrelease  => '14.04',
        :lsbdistcodename => 'trusty',
        :operatingsystem => 'Ubuntu',
        :lsbdistid       => 'Ubuntu',
        :osfamily        => 'Debian',
      }
    end
    let :params do
      {
        'options' => '',
      }
    end
    let(:title) { 'ppa:foo' }
    it { is_expected.to contain_package('software-properties-common') }
    it { is_expected.to contain_exec('add-apt-repository-ppa:foo').that_notifies('Exec[apt_update]').with({
      'environment' => [],
      'command'     => '/usr/bin/add-apt-repository  ppa:foo',
      'unless'      => '/usr/bin/test -s /etc/apt/sources.list.d/foo-trusty.list',
      'user'        => 'root',
      'logoutput'   => 'on_failure',
    })
    }

    it { is_expected.to contain_file('/etc/apt/sources.list.d/foo-trusty.list').that_requires('Exec[add-apt-repository-ppa:foo]').with({
      'ensure' => 'file',
    })
    }
  end

  describe 'apt included, proxy' do
    let :pre_condition do
      'class { "apt": proxy_host => "example.com" }'
    end
    let :facts do
      {
        :lsbdistrelease  => '14.04',
        :lsbdistcodename => 'trusty',
        :operatingsystem => 'Ubuntu',
        :lsbdistid       => 'Ubuntu',
        :osfamily        => 'Debian',
      }
    end
    let :params do
      {
        'release' => 'lucid',
      }
    end
    let(:title) { 'ppa:foo' }
    it { is_expected.to contain_package('software-properties-common') }
    it { is_expected.to contain_exec('add-apt-repository-ppa:foo').that_notifies('Exec[apt_update]').with({
      'environment' => ['http_proxy=http://example.com:8080', 'https_proxy=http://example.com:8080'],
      'command'     => '/usr/bin/add-apt-repository -y ppa:foo',
      'unless'      => '/usr/bin/test -s /etc/apt/sources.list.d/foo-lucid.list',
      'user'        => 'root',
      'logoutput'   => 'on_failure',
    })
    }

    it { is_expected.to contain_file('/etc/apt/sources.list.d/foo-lucid.list').that_requires('Exec[add-apt-repository-ppa:foo]').with({
      'ensure' => 'file',
    })
    }
  end

  describe 'ensure absent' do
    let :facts do
      {
        :lsbdistrelease  => '14.04',
        :lsbdistcodename => 'trusty',
        :operatingsystem => 'Ubuntu',
        :lsbdistid       => 'Ubuntu',
        :osfamily        => 'Debian',
      }
    end
    let(:title) { 'ppa:foo' }
    let :params do
      {
        'ensure' => 'absent'
      }
    end
    it { is_expected.to contain_file('/etc/apt/sources.list.d/foo-trusty.list').that_notifies('Exec[apt_update]').with({
      'ensure' => 'absent',
    })
    }
  end

  context 'validation' do
    describe 'no release' do
      let :facts do
        {
          :lsbdistrelease  => '14.04',
          :operatingsystem => 'Ubuntu',
          :lsbdistid       => 'Ubuntu',
          :osfamily        => 'Debian',
        }
      end
      let(:title) { 'ppa:foo' }
      it do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /lsbdistcodename fact not available: release parameter required/)
      end
    end

    describe 'not ubuntu' do
      let :facts do
        {
          :lsbdistrelease  => '14.04',
          :lsbdistcodename => 'trusty',
          :operatingsystem => 'Debian',
          :lsbdistid       => 'Ubuntu',
          :osfamily        => 'Debian',
        }
      end
      let(:title) { 'ppa:foo' }
      it do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /apt::ppa is currently supported on Ubuntu only./)
      end
    end
  end
end
