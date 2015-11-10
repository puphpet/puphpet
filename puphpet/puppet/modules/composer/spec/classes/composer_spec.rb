require 'spec_helper'

describe 'composer' do

  shared_examples 'a composer module' do |params, ctx|
    p = {
      :php_package     => 'php-cli',
      :php_bin         => 'php',
      :curl_package    => 'curl',
      :target_dir      => '/usr/local/bin',
      :composer_file   => 'composer',
      :suhosin_enabled => true,
    }

    p.merge!(params) if params

    c = {
      :php_context     => '/files/etc/php.ini/PHP',
      :suhosin_context => '/files/etc/suhosin.ini/suhosin',
    }

    c.merge!(ctx) if ctx

    composer_path = "#{p[:target_dir]}/#{p[:composer_file]}"

    it 'should compile' do
      compile
    end

    it { should contain_class('composer::params') }

    it {
      should contain_exec('download_composer').with({
        :command     => "curl -s https://getcomposer.org/installer | #{p[:php_bin]}",
        :cwd         => '/tmp',
        :creates     => '/tmp/composer.phar',
        :logoutput   => false,
      })
    }

    it { should contain_package(p[:php_package]).with_ensure('present') }
    it { should contain_package(p[:curl_package]).with_ensure('present') }
    it { should contain_file(p[:target_dir]).with_ensure('directory') }

    it {
      should contain_file(composer_path).with({
        :source => 'present',
        :source => '/tmp/composer.phar',
        :mode   => '0755',
      })
    }

    if p[:suhosin_enabled] then
      it_behaves_like 'composer with suhosin', c
    else
      it_behaves_like 'composer without suhosin'
    end

    if p.include? :github_token then
      it_behaves_like 'it sets a github token', composer_path, p[:github_token]
    end
  end

  shared_examples 'composer with suhosin' do |ctx|
      it {
        should contain_augeas('whitelist_phar').with({
          :context     => ctx[:suhosin_context],
          :changes     => 'set suhosin.executor.include.whitelist phar',
        })
      }

      it {
        should contain_augeas('allow_url_fopen').with({
          :context    => ctx[:php_context],
          :changes    => 'set allow_url_fopen On',
        })
      }
  end

  shared_examples 'composer without suhosin' do
    it { should_not contain_augeas('whitelist_phar') }
    it { should_not contain_augeas('allow_url_fopen') }
  end

  shared_examples 'it sets a github token' do |path, token|
    it {
      should contain_exec('setup_github_token').with({
        :command => "#{path} config -g github-oauth.github.com #{token}",
        :cwd     => '/tmp',
        :unless  => "#{path} config -g github-oauth.github.com|grep #{token}",
      })
    }
  end

  shared_examples 'a composer module with projects' do |params, ctx|
    p = {
      :projects => {
          'pkg1' => { 'project_name' => 'pkg1', 'target_dir' => '/home/pkg1' },
          'pkg2' => { 'project_name' => 'pkg2', 'target_dir' => '/home/pkg2' },
      }
    }

    p.merge!(params)

    let(:params) { p }

    it_behaves_like 'a composer module', p, ctx

    it {
      should contain_composer__project('pkg1').with({
        'project_name' => 'pkg1',
        'target_dir'   => '/home/pkg1',
      })
    }

    it {
      should contain_composer__project('pkg2').with({
        'project_name' => 'pkg2',
        'target_dir'   => '/home/pkg2',
      })
    }

    it { should have_composer__project_resource_count(2) }
  end

  ['RedHat', 'Debian', 'Linux'].each do |osfamily|
    case osfamily
    when 'RedHat'
      params = {}
      ctx = {
        :php_context     => '/files/etc/php.ini/PHP',
        :suhosin_context => '/files/etc/suhosin.ini/suhosin',
      }
    when 'Debian'
      params = {
        :php_package => 'php5-cli'
      }
      ctx = {
        :php_context     => '/files/etc/php5/cli/php.ini/PHP',
        :suhosin_context => '/files/etc/php5/conf.d/suhosin.ini/suhosin',
      }
    when 'Linux'
      params = {}
      ctx = {}
    end
    context "for osfamily #{osfamily}" do
      let(:facts) { {
        :osfamily        => osfamily,
        :operatingsystem => 'Amazon'
      } }
      context 'with defaults' do
        it_behaves_like 'a composer module', params, ctx
      end
      context 'with custom parameters' do
        custom_params = {
          :target_dir      => '/you_sir/lowcal/been',
          :php_package     => 'php8-cli',
          :composer_file   => 'compozah',
          :curl_package    => 'kerl',
          :php_bin         => 'pehpe',
          :suhosin_enabled => false,
          :github_token    => 'my_token',
        }
        let(:params) { custom_params }
        it_behaves_like 'a composer module', custom_params, ctx
      end
      context 'with projects' do
        it_behaves_like 'a composer module with projects', params, ctx
      end
    end
  end

  context 'for operatingsystem Ubuntu' do
    facts  = { :osfamily    => 'Debian', :operatingsystem => 'Ubuntu' }
    params = { :php_package => 'php5-cli' }
    ctx    = {
      :php_context     => '/files/etc/php5/cli/php.ini/PHP',
      :suhosin_context => '/files/etc/php5/conf.d/suhosin.ini/suhosin',
    }

    context "for releases with php53" do
      let(:facts) { { :operatingsystemmajrelease => '12.04' }.merge! facts }
      context 'with defaults' do
        it_behaves_like 'a composer module', params, ctx
      end
    end

    ['12.10', '13.04', '13.10', '14.04, 14.10'].each do |release|
      context "for release #{release} with php54" do
        let(:facts) { { :operatingsystemmajrelease => release }.merge! facts }
        context 'disables suhosin by default' do
          it_behaves_like 'composer without suhosin'
        end
      end
    end
  end

  context "for invalid operating system family" do
    let(:facts) { {
      :osfamily        => 'Invalid',
      :operatingsystem => 'Amazon'
    } }

    it 'should not compile' do
      expect { should compile }.to raise_error(/Unsupported platform: Invalid/)
    end
  end
end
