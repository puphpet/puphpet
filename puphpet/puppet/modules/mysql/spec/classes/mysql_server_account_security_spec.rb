require 'spec_helper'

describe 'mysql::server::account_security' do
  on_pe_supported_platforms(PLATFORMS).each do |pe_version,pe_platforms|
    pe_platforms.each do |pe_platform,facts|
      describe "on #{pe_version} #{pe_platform}" do
        let(:facts) { facts.merge({:fqdn => 'myhost.mydomain', :hostname => 'myhost'}) }

        [ 'root@myhost.mydomain',
          'root@127.0.0.1',
          'root@::1',
          '@myhost.mydomain',
          '@localhost',
          '@%',
        ].each do |user|
          it "removes Mysql_User[#{user}]" do
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end

        # When the hostname doesn't match the fqdn we also remove these.
        # We don't need to test the inverse as when they match they are
        # covered by the above list.
        [ 'root@myhost', '@myhost' ].each do |user|
          it "removes Mysql_User[#{user}]" do
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end

        it 'should remove Mysql_database[test]' do
          is_expected.to contain_mysql_database('test').with_ensure('absent')
        end
      end

      describe "on #{pe_version} #{pe_platform} with fqdn==localhost" do
        let(:facts) { facts.merge({:fqdn => 'localhost', :hostname => 'localhost'}) }

        [ 'root@127.0.0.1',
          'root@::1',
          '@localhost',
          'root@localhost.localdomain',
          '@localhost.localdomain',
          '@%',
        ].each do |user|
          it "removes Mysql_User[#{user}]" do
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end
      end

      describe "on #{pe_version} #{pe_platform} with fqdn==localhost.localdomain" do
        let(:facts) { facts.merge({:fqdn => 'localhost.localdomain', :hostname => 'localhost'}) }

        [ 'root@127.0.0.1',
          'root@::1',
          '@localhost',
          'root@localhost.localdomain',
          '@localhost.localdomain',
          '@%',
        ].each do |user|
          it "removes Mysql_User[#{user}]" do
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end
      end
    end
  end
end
