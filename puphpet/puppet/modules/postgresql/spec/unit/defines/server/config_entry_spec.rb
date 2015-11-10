require 'spec_helper'

describe 'postgresql::server::config_entry', :type => :define do
  let :facts do
    {
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
      :operatingsystemrelease => '6.4',
      :kernel => 'Linux',
      :concat_basedir => tmpfilename('contrib'),
      :id => 'root',
      :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end

  let(:title) { 'config_entry'}

  let :target do
    tmpfilename('postgresql_conf')
  end

  let :pre_condition do
    "class {'postgresql::server':}"
  end

  context "syntax check" do
    let(:params) { { :ensure => 'present'} }
    it { is_expected.to contain_postgresql__server__config_entry('config_entry') }
  end

  context 'ports' do
    context 'redhat 6' do
      let :facts do
        {
          :osfamily => 'RedHat',
          :operatingsystem => 'RedHat',
          :operatingsystemrelease => '6.4',
          :kernel => 'Linux',
          :concat_basedir => tmpfilename('contrib'),
          :id => 'root',
          :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        }
      end
      let(:params) {{ :ensure => 'present', :name => 'port_spec', :value => '5432' }}

      it 'stops postgresql and changes the port' do
        is_expected.to contain_exec('postgresql_stop_port')
        is_expected.to contain_augeas('override PGPORT in /etc/sysconfig/pgsql/postgresql')
      end
    end
    context 'redhat 7' do
      let :facts do
        {
          :osfamily => 'RedHat',
          :operatingsystem => 'RedHat',
          :operatingsystemrelease => '7.0',
          :kernel => 'Linux',
          :concat_basedir => tmpfilename('contrib'),
          :id => 'root',
          :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        }
      end
      let(:params) {{ :ensure => 'present', :name => 'port_spec', :value => '5432' }}

      it 'stops postgresql and changes the port' do
        is_expected.to contain_file('systemd-override')
        is_expected.to contain_exec('restart-systemd')
      end
    end
    context 'fedora 19' do
      let :facts do
        {
          :osfamily => 'RedHat',
          :operatingsystem => 'Fedora',
          :operatingsystemrelease => '19',
          :kernel => 'Linux',
          :concat_basedir => tmpfilename('contrib'),
          :id => 'root',
          :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        }
      end
      let(:params) {{ :ensure => 'present', :name => 'port_spec', :value => '5432' }}

      it 'stops postgresql and changes the port' do
        is_expected.to contain_file('systemd-override')
        is_expected.to contain_exec('restart-systemd')
      end
    end
  end

  context "data_directory" do
    let(:params) {{ :ensure => 'present', :name => 'data_directory_spec', :value => '/var/pgsql' }}

    it 'stops postgresql and changes the data directory' do
      is_expected.to contain_exec('postgresql_data_directory')
      is_expected.to contain_augeas('override PGDATA in /etc/sysconfig/pgsql/postgresql')
    end
  end

  context "passes values through appropriately" do
    let(:params) {{ :ensure => 'present', :name => 'check_function_bodies', :value => 'off' }}

    it 'with no quotes' do
      is_expected.to contain_postgresql_conf('check_function_bodies').with({
        :name  => 'check_function_bodies',
        :value => 'off' })
    end
  end
end
