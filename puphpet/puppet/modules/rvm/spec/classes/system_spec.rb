require 'spec_helper'

describe 'rvm::system' do

  # assume RVM is already installed
  let(:facts) {{
    :rvm_version => '1.10.0',
    :root_home => '/root'
  }}

  context "default parameters", :compile do
    it { should_not contain_exec('system-rvm-get') }
  end

  context "with present version", :compile do
    let(:params) {{ :version => 'present' }}
    it { should_not contain_exec('system-rvm-get') }
  end

  context "with latest version", :compile do
    let(:params) {{ :version => 'latest' }}
    it { should contain_exec('system-rvm-get').with_command('rvm get latest') }
  end

  context "with explicit version", :compile do
    let(:params) {{ :version => '1.20.0' }}
    it { should contain_exec('system-rvm-get').with_command('rvm get 1.20.0') }
  end

  context "with proxy_url parameter", :compile do
    let(:params) {{ :version => 'latest', :proxy_url => 'http://dummy.bogus.local:8080' }}
    it { should contain_exec('system-rvm-get').with_environment("[\"http_proxy=#{params[:proxy_url]}\", \"https_proxy=#{params[:proxy_url]}\", \"HOME=/root\"]") }
  end

  context "with no_proxy parameter", :compile do
    let(:params) {{ :version => 'latest', :proxy_url => 'http://dummy.bogus.local:8080', :no_proxy => '.example.local' }}
    it { should contain_exec('system-rvm-get').with_environment("[\"http_proxy=#{params[:proxy_url]}\", \"https_proxy=#{params[:proxy_url]}\", \"no_proxy=#{params[:no_proxy]}\", \"HOME=/root\"]") }
  end

end
