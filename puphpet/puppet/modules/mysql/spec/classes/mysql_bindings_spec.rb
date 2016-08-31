require 'spec_helper'

describe 'mysql::bindings' do
  on_pe_supported_platforms(PLATFORMS).each do |pe_version,pe_platforms|
    pe_platforms.each do |pe_platform,facts|
      describe "on #{pe_version} #{pe_platform}" do
        let(:facts) { facts }

        let(:params) {{
          'java_enable'             => true,
          'perl_enable'             => true,
          'php_enable'              => true,
          'python_enable'           => true,
          'ruby_enable'             => true,
          'client_dev'              => true,
          'daemon_dev'              => true,
          'client_dev_package_name' => 'libmysqlclient-devel',
          'daemon_dev_package_name' => 'mysql-devel',
        }}

        it { is_expected.to contain_package('mysql-connector-java') }
        it { is_expected.to contain_package('perl_mysql') }
        it { is_expected.to contain_package('python-mysqldb') }
        it { is_expected.to contain_package('ruby_mysql') }
        it { is_expected.to contain_package('mysql-client_dev') }
        it { is_expected.to contain_package('mysql-daemon_dev') }
      end
    end
  end
end
