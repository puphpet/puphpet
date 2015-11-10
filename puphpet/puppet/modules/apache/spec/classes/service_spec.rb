require 'spec_helper'

describe 'apache::service', :type => :class do
  let :pre_condition do
    'include apache::params'
  end
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :lsbdistcodename        => 'squeeze',
        :operatingsystem        => 'Debian',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_service("httpd").with(
      'name'      => 'apache2',
      'ensure'    => 'running',
      'enable'    => 'true'
      )
    }

    context "with $service_name => 'foo'" do
      let (:params) {{ :service_name => 'foo' }}
      it { is_expected.to contain_service("httpd").with(
        'name'      => 'foo'
        )
      }
    end

    context "with $service_enable => true" do
      let (:params) {{ :service_enable => true }}
      it { is_expected.to contain_service("httpd").with(
        'name'      => 'apache2',
        'ensure'    => 'running',
        'enable'    => 'true'
        )
      }
    end

    context "with $service_enable => false" do
      let (:params) {{ :service_enable => false }}
      it { is_expected.to contain_service("httpd").with(
        'name'      => 'apache2',
        'ensure'    => 'running',
        'enable'    => 'false'
        )
      }
    end

    context "$service_enable must be a bool" do
      let (:params) {{ :service_enable => 'not-a-boolean' }}

      it 'should fail' do
        expect { subject }.to raise_error(Puppet::Error, /is not a boolean/)
      end
    end

    context "$service_manage must be a bool" do
      let (:params) {{ :service_manage => 'not-a-boolean' }}

      it 'should fail' do
        expect { subject }.to raise_error(Puppet::Error, /is not a boolean/)
      end
    end

    context "with $service_ensure => 'running'" do
      let (:params) {{ :service_ensure => 'running', }}
      it { is_expected.to contain_service("httpd").with(
        'ensure'    => 'running',
        'enable'    => 'true'
        )
      }
    end

    context "with $service_ensure => 'stopped'" do
      let (:params) {{ :service_ensure => 'stopped', }}
      it { is_expected.to contain_service("httpd").with(
        'ensure'    => 'stopped',
        'enable'    => 'true'
        )
      }
    end

    context "with $service_ensure => 'UNDEF'" do
      let (:params) {{ :service_ensure => 'UNDEF' }}
      it { is_expected.to contain_service("httpd").without_ensure }
    end
  end


  context "on a RedHat 5 OS, do not manage service" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '5',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'RedHat',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    let(:params) do
      {
        'service_ensure' => 'running',
        'service_name'   => 'httpd',
        'service_manage' => false
      }
    end
    it 'should not manage the httpd service' do
      subject.should_not contain_service('httpd')
    end
  end

  context "on a FreeBSD 5 OS" do
    let :facts do
      {
        :osfamily               => 'FreeBSD',
        :operatingsystemrelease => '9',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'FreeBSD',
        :id                     => 'root',
        :kernel                 => 'FreeBSD',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_service("httpd").with(
      'name'      => 'apache24',
      'ensure'    => 'running',
      'enable'    => 'true'
      )
    }
  end

  context "on a Gentoo OS" do
    let :facts do
      {
        :osfamily               => 'Gentoo',
        :operatingsystem        => 'Gentoo',
        :operatingsystemrelease => '3.16.1-gentoo',
        :concat_basedir         => '/dne',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_service("httpd").with(
      'name'      => 'apache2',
      'ensure'    => 'running',
      'enable'    => 'true'
      )
    }
  end
end
