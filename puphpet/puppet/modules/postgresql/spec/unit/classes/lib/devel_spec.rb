require 'spec_helper'

describe 'postgresql::lib::devel', :type => :class do
  let :facts do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
    }
  end
  it { is_expected.to contain_class("postgresql::lib::devel") }

  describe 'link pg_config to /usr/bin' do
    it { should_not contain_file('/usr/bin/pg_config') \
      .with_ensure('link') \
      .with_target('/usr/lib/postgresql/8.4/bin/pg_config')
    }
  end

  describe 'disable link_pg_config' do
    let(:params) {{
      :link_pg_config => false,
    }}
    it { should_not contain_file('/usr/bin/pg_config') }
  end

  describe 'should not link pg_config on RedHat with default version' do
    let(:facts) {{
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'CentOS',
      :operatingsystemrelease    => '6.3',
      :operatingsystemmajrelease => '6',
    }}
    it { should_not contain_file('/usr/bin/pg_config') }
  end

  describe 'link pg_config on RedHat with non-default version' do
    let(:facts) {{
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'CentOS',
      :operatingsystemrelease    => '6.3',
      :operatingsystemmajrelease => '6',
    }}
    let :pre_condition do
    "class { '::postgresql::globals': version => '9.3' }"
    end

    it { should contain_file('/usr/bin/pg_config') \
      .with_ensure('link') \
      .with_target('/usr/pgsql-9.3/bin/pg_config')
    }
  end

end
