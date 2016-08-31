require 'spec_helper'

describe 'composer::selfupdate' do
  ['RedHat', 'Debian'].each do |osfamily|
    context "on #{osfamily} operating system family" do
      let(:facts) { {
          :osfamily => osfamily,
      } }

      context 'with default params' do
        it { should contain_class('composer') }
        let(:title) { 'auto_update' }
        
        it {
          should contain_exec('composer_selfupdate_auto_update').with({
            :command => %r{php /usr/local/bin/composer selfupdate},
            :tries   => 3,
            :timeout => 300,
          })
        }
      end
      context 'with clean backup params' do
        it { should contain_class('composer') }
        let(:title) { 'another_update' }
        let(:params) { {
          :clean_backups => true,
          :version       => '12354eaf43',
          :tries         => 6,
          :timeout       => 150,
        } }
        it {
          should contain_exec('composer_selfupdate_another_update').without_user().with({
            :command => %r{php /usr/local/bin/composer selfupdate --clean-backups 12354eaf43},
            :tries   => 6,
            :timeout => 150,
          })
        }
      end
      context 'with rollback params' do
        it { should contain_class('composer') }
        let(:title) { 'rollback_update' }
        let(:params) { {
          :rollback      => true,
          :clean_backups => true,
          :version       => '12354eaf43',
          :user          => 'mrploch',
        } }
        it {
          should contain_exec('composer_selfupdate_rollback_update').with({
            :command => %r{php /usr/local/bin/composer selfupdate --rollback --clean-backups 12354eaf43},
            :tries   => 3,
            :timeout => 300,
            :user    => 'mrploch',
          })
        }
      end
      context 'with rollback missing verion' do
        let(:title) { 'rollback_without_version' }
        let(:params) { {
          :rollback => true,
        } }
        it 'should not compile' do
          expect { should compile }.to raise_error(/You cannot use rollback without specifying a version/)
        end
      end
    end
  end
end

