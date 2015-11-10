require 'spec_helper'

describe 'mysql::server::mysqltuner' do
  on_pe_supported_platforms(PLATFORMS).each do |pe_version,pe_platforms|
    pe_platforms.each do |pe_platform,facts|
      describe "on #{pe_version} #{pe_platform}" do
        let(:facts) { facts }

        context 'ensure => present' do
          it { is_expected.to compile }
          it { is_expected.to contain_staging__file('mysqltuner-v1.3.0').with({
            :source => 'https://github.com/major/MySQLTuner-perl/raw/v1.3.0/mysqltuner.pl',
          })
          }
        end

        context 'ensure => absent' do
          let(:params) {{ :ensure => 'absent' }}
          it { is_expected.to compile }
          it { is_expected.to contain_file('/usr/local/bin/mysqltuner').with(:ensure => 'absent') }
        end

        context 'custom version' do
          let(:params) {{ :version => 'v1.2.0' }}
          it { is_expected.to compile }
          it { is_expected.to contain_staging__file('mysqltuner-v1.2.0').with({
            :source => 'https://github.com/major/MySQLTuner-perl/raw/v1.2.0/mysqltuner.pl',
          })
          }
        end

        context 'custom source' do
          let(:params) {{ :source => '/tmp/foo' }}
          it { is_expected.to compile }
          it { is_expected.to contain_staging__file('mysqltuner-/tmp/foo').with({
            :source => '/tmp/foo',
          })
          }
        end
      end
    end
  end
end
