require 'spec_helper'

describe 'rvm' do

  let(:facts) {{
    :rvm_version => '',
    :root_home => '/root'
  }}

  context "default parameters", :compile do
    it { should_not contain_class('rvm::dependencies') }
    it { should contain_class('rvm::system') }
  end

  context "with install_rvm false", :compile do
    let(:params) {{
      :install_rvm => false
    }}
    it { should_not contain_class('rvm::dependencies') }
    it { should_not contain_class('rvm::system') }
  end

  context "with system_rubies", :compile do
    let(:params) {{
      :system_rubies => {
        'ruby-1.9' => {
          'default_use' => true
        },
        'ruby-2.0' => {}
      }
    }}
    it { should contain_rvm_system_ruby('ruby-1.9').with({
      :ensure => 'present',
      :default_use => true
    }) }
    it { should contain_rvm_system_ruby('ruby-2.0').with({
      :ensure => 'present',
      :default_use => nil
    }) }
  end

  context "with system_users", :compile do
    let(:params) {{ :system_users => ['john','doe'] }}
    it { should contain_rvm__system_user('john') }
    it { should contain_rvm__system_user('doe') }
  end
end
