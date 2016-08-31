require 'spec_helper'

describe 'mysql::client' do
  on_pe_supported_platforms(PLATFORMS).each do |pe_version,pe_platforms|
    pe_platforms.each do |pe_platform,facts|
      describe "on #{pe_version} #{pe_platform}" do
        let(:facts) { facts }

        context 'with defaults' do
          it { is_expected.not_to contain_class('mysql::bindings') }
          it { is_expected.to contain_package('mysql_client') }
        end

        context 'with bindings enabled' do
          let(:params) {{ :bindings_enable => true }}

          it { is_expected.to contain_class('mysql::bindings') }
          it { is_expected.to contain_package('mysql_client') }
        end

        context 'with package_manage set to true' do
          let(:params) {{ :package_manage => true }}

          it { is_expected.to contain_package('mysql_client') }
        end

        context 'with package_manage set to false' do
          let(:params) {{ :package_manage => false }}

          it { is_expected.not_to contain_package('mysql_client') }
        end

      end
    end
  end
end
