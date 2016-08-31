require 'spec_helper'

describe 'mysql::server' do
  context 'my.cnf template' do
    on_pe_supported_platforms(PLATFORMS).each do |pe_version,pe_platforms|
      pe_platforms.each do |pe_platform,facts|
        describe "on #{pe_version} #{pe_platform}" do
          let(:facts) { facts }

          context 'normal entry' do
            let(:params) {{ :override_options => { 'mysqld' => { 'socket' => '/var/lib/mysql/mysql.sock' } } }}
            it do
              is_expected.to contain_file('mysql-config-file').with({
                :mode => '0644',
              }).with_content(/socket = \/var\/lib\/mysql\/mysql.sock/)
            end
          end

          describe 'array entry' do
            let(:params) {{ :override_options => { 'mysqld' => { 'replicate-do-db' => ['base1', 'base2'], } }}}
            it do
              is_expected.to contain_file('mysql-config-file').with_content(
                /.*replicate-do-db = base1\nreplicate-do-db = base2.*/
              )
            end
          end

          describe 'ssl set to true' do
            let(:params) {{ :override_options => { 'mysqld' => { 'ssl' => true }}}}
            it { is_expected.to contain_file('mysql-config-file').with_content(/ssl/) }
            it { is_expected.to contain_file('mysql-config-file').without_content(/ssl = true/) }
          end

          describe 'ssl set to false' do
            let(:params) {{ :override_options => { 'mysqld' => { 'ssl' => false }}}}
            it { is_expected.to contain_file('mysql-config-file').with_content(/ssl = false/) }
          end

          # ssl-disable (and ssl) are special cased within mysql.
          describe 'possibility of disabling ssl completely' do
            let(:params) {{ :override_options => { 'mysqld' => { 'ssl' => true, 'ssl-disable' => true }}}}
            it { is_expected.to contain_file('mysql-config-file').without_content(/ssl = true/) }
          end

          describe 'a non ssl option set to true' do
            let(:params) {{ :override_options => { 'mysqld' => { 'test' => true }}}}
            it { is_expected.to contain_file('mysql-config-file').with_content(/^test$/) }
            it { is_expected.to contain_file('mysql-config-file').without_content(/test = true/) }
          end

          context 'with includedir' do
            let(:params) {{ :includedir => '/etc/my.cnf.d' }}
            it 'makes the directory' do
              is_expected.to contain_file('/etc/my.cnf.d').with({
                :ensure => :directory,
                :mode   => '0755',
              })
            end

            it { is_expected.to contain_file('mysql-config-file').with_content(/!includedir/) }
          end

          context 'without includedir' do
            let(:params) {{ :includedir => '' }}
            it 'shouldnt contain the directory' do
              is_expected.not_to contain_file('mysql-config-file').with({
                :ensure => :directory,
                :mode   => '0755',
              })
            end

            it { is_expected.to contain_file('mysql-config-file').without_content(/!includedir/) }
          end
        end
      end
    end
  end
end
