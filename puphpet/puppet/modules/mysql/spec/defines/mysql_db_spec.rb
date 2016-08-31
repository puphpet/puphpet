require 'spec_helper'

describe 'mysql::db', :type => :define do
  on_pe_supported_platforms(PLATFORMS).each do |pe_version,pe_platforms|
    pe_platforms.each do |pe_platform,facts|
      describe "on #{pe_version} #{pe_platform}" do
        let(:facts) { facts }

        let(:title) { 'test_db' }

        let(:params) {
          { 'user'     => 'testuser',
            'password' => 'testpass',
          }
        }

        it 'should report an error when ensure is not present or absent' do
          params.merge!({'ensure' => 'invalid_val'})
          expect { subject }.to raise_error(Puppet::Error,
                                            /invalid_val is not supported for ensure\. Allowed values are 'present' and 'absent'\./)
        end

        it 'should not notify the import sql exec if no sql script was provided' do
          is_expected.to contain_mysql_database('test_db').without_notify
        end

        it 'should subscribe to database if sql script is given' do
          params.merge!({'sql' => 'test_sql'})
          is_expected.to contain_exec('test_db-import').with_subscribe('Mysql_database[test_db]')
        end

        it 'should only import sql script on creation if not enforcing' do
          params.merge!({'sql' => 'test_sql', 'enforce_sql' => false})
          is_expected.to contain_exec('test_db-import').with_refreshonly(true)
        end

        it 'should import sql script on creation if enforcing' do
          params.merge!({'sql' => 'test_sql', 'enforce_sql' => true})
          is_expected.to contain_exec('test_db-import').with_refreshonly(false)
          is_expected.to contain_exec('test_db-import').with_command("cat test_sql | mysql test_db")
        end

        it 'should import sql scripts when more than one is specified' do
          params.merge!({'sql' => ['test_sql', 'test_2_sql']})
          is_expected.to contain_exec('test_db-import').with_command('cat test_sql test_2_sql | mysql test_db')
        end

        it 'should report an error if sql isn\'t a string or an array' do
          params.merge!({'sql' => {'foo' => 'test_sql', 'bar' => 'test_2_sql'}})
          expect { subject }.to raise_error(Puppet::Error,
                                            /\$sql must be either a string or an array\./)
        end

        it 'should not create database and database user' do
          params.merge!({'ensure' => 'absent', 'host' => 'localhost'})
          is_expected.to contain_mysql_database('test_db').with_ensure('absent')
          is_expected.to contain_mysql_user('testuser@localhost').with_ensure('absent')
        end

        it 'should create with an appropriate collate and charset' do
          params.merge!({'charset' => 'utf8', 'collate' => 'utf8_danish_ci'})
          is_expected.to contain_mysql_database('test_db').with({
            'charset' => 'utf8',
            'collate' => 'utf8_danish_ci',
          })
        end

        it 'should use dbname parameter as database name instead of name' do
          params.merge!({'dbname' => 'real_db'})
          is_expected.to contain_mysql_database('real_db')
        end
      end
    end
  end
end
