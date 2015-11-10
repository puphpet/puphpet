require 'spec_helper'

describe 'postgresql::server::database', :type => :define do
  let :facts do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
      :kernel => 'Linux',
      :concat_basedir => tmpfilename('contrib'),
      :id => 'root',
      :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end
  let :title do
    'test'
  end

  let :pre_condition do
    "class {'postgresql::server':}"
  end

  it { is_expected.to contain_postgresql__server__database('test') }
  it { is_expected.to contain_postgresql_psql("Check for existence of db 'test'") }

  context "with comment set to 'test comment'" do
    let (:params) {{ :comment => 'test comment' }}

    it { is_expected.to contain_postgresql_psql("COMMENT ON DATABASE test IS 'test comment'") }
  end
end
