require 'spec_helper'

describe 'postgresql::server::pg_ident_rule', :type => :define do
  let :facts do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
      :kernel => 'Linux',
      :concat_basedir => tmpfilename('pg_ident'),
      :id => 'root',
      :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end
  let :title do
    'test'
  end
  let :target do
    tmpfilename('pg_ident_rule')
  end

  context 'managing pg_ident' do
    let :pre_condition do
      <<-EOS
        class { 'postgresql::globals':
          manage_pg_ident_conf => true,
        }
        class { 'postgresql::server': }
      EOS
    end

    let :params do
      {
        :map_name => 'thatsmymap',
        :system_username => 'systemuser',
        :database_username => 'dbuser',
      }
    end
    it do
      is_expected.to contain_concat__fragment('pg_ident_rule_test').with({
        :content => /thatsmymap\s+systemuser\s+dbuser/
      })
    end
  end
  context 'not managing pg_ident' do
    let :pre_condition do
      <<-EOS
        class { 'postgresql::globals':
          manage_pg_ident_conf => false,
        }
        class { 'postgresql::server': }
      EOS
    end
    let :params do
      {
          :map_name => 'thatsmymap',
          :system_username => 'systemuser',
          :database_username => 'dbuser',
      }
    end
    it 'should fail because $manage_pg_ident_conf is false' do
      expect {subject}.to raise_error(Puppet::Error,
                                      /postgresql::server::manage_pg_ident_conf has been disabled/)
    end
  end
end
