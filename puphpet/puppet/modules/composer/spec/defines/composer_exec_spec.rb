require 'spec_helper'

describe 'composer::exec' do
  ['RedHat', 'Debian'].each do |osfamily|
    context "on #{osfamily} operating system family" do
      let(:facts) { {
          :osfamily => osfamily,
      } }

      context 'using install command' do
        it { should contain_class('git') }
        it { should contain_class('stdlib') }
        it { should contain_class('composer') }

        let(:title) { 'myproject' }
        let(:params) { {
          :cmd     => 'install',
          :cwd     => '/my/awesome/project',
          :user    => 'linus',
          :timeout => 1267,
          :onlyif  => 'test ! -f /my/awesome/project',
        } }

        it {
          should contain_exec('composer_install_myproject').with({
            :command   => %r{php /usr/local/bin/composer install --no-plugins --no-scripts --no-interaction},
            :cwd       => '/my/awesome/project',
            :user      => 'linus',
            :logoutput => false,
            :timeout   => 1267,
            :onlyif    => 'test ! -f /my/awesome/project',
          })
        }
      end

      context 'using update command' do
        it { should contain_class('git') }
        it { should contain_class('stdlib') }
        it { should contain_class('composer') }

        let(:title) { 'yourpr0ject' }
        let(:params) { {
          :cmd       => 'update',
          :cwd       => '/just/in/time',
          :packages  => ['package1', 'packageinf'],
          :logoutput => true,
          :unless  => '/just/in/time/bin/entry --version | grep 2\.0\.6',
        } }

        it {
          should contain_exec('composer_update_yourpr0ject').without_user.without_timeout.with({
            :command   => %r{php /usr/local/bin/composer update --no-plugins --no-scripts --no-interaction package1 packageinf},
            :cwd       => '/just/in/time',
            :logoutput => true,
            :unless    => '/just/in/time/bin/entry --version | grep 2\.0\.6',
          })
        }
      end

      context 'using require command' do
        it { should contain_class('git') }
        it { should contain_class('composer') }

        let(:title) { 'yourpr0ject' }
        let(:params) { {
          :cmd       => 'require',
          :cwd       => '/just/in/time',
          :packages  => ['package1', 'packageinf'],
          :logoutput => 'on_failure',
          :dev       => false,
        } }

        it {
          should contain_exec('composer_require_yourpr0ject').without_user.with({
            :command   => %r{php /usr/local/bin/composer require package1 packageinf},
            :cwd       => '/just/in/time',
            :logoutput => 'on_failure',
          })
        }
      end
    end
  end

  context 'on unsupported operating system family' do
    let(:facts) { {
      :osfamily => 'Darwin',
    } }

    let(:title) { 'someproject' }

    it 'should not compile' do
      expect { should compile }.to raise_error(/Unsupported platform: Darwin/)
    end
  end
end
