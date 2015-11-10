require 'spec_helper'
describe 'mysql::server::monitor' do
  on_pe_supported_platforms(PLATFORMS).each do |pe_version,pe_platforms|
    pe_platforms.each do |pe_platform,facts|
      describe "on #{pe_version} #{pe_platform}" do
        let(:facts) { facts }
        let :pre_condition do
          "include 'mysql::server'"
        end

        let :default_params do
          {
            :mysql_monitor_username   => 'monitoruser',
            :mysql_monitor_password   => 'monitorpass',
            :mysql_monitor_hostname   => 'monitorhost',
          }
        end

        let :params do
          default_params
        end

        it { is_expected.to contain_mysql_user('monitoruser@monitorhost')}

        it { is_expected.to contain_mysql_grant('monitoruser@monitorhost/*.*').with(
          :ensure     => 'present',
          :user       => 'monitoruser@monitorhost',
          :table      => '*.*',
          :privileges => ["PROCESS", "SUPER"],
          :require    => 'Mysql_user[monitoruser@monitorhost]'
        )}
      end
    end
  end
end
