require 'spec_helper'

describe 'rvm::rvmrc' do
  let(:file) { '/etc/rvmrc' }
  let(:pre_condition) { "exec {'system-rvm': path => '/bin'}" }

  context "default parameters", :compile do
    it { should contain_file(file).with_group('rvm') }
    it { should contain_file(file).with_content(%r{^umask u=rwx,g=rwx,o=rx$}) }
    it { should contain_file(file).with_content(%r{^rvm_autoupdate_flag=0$}) }
    it { should_not contain_file(file).with_content(%r{rvm_max_time_flag}) }
  end

  context "with max_time_flag", :compile do
    let(:params) {{ :max_time_flag => 20 }}
    it { should contain_file(file).with_content(%r{^export rvm_max_time_flag=20$}) }
  end

end
