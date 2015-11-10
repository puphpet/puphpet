require 'spec_helper'

describe 'rvm::system_user' do

  let(:username) { 'johndoe' }
  let(:group) { 'rvm' }
  let(:title) { username }

  context "when using default parameters", :compile do
    it { should contain_user(username) }
    it { should contain_group(group) }
    it { should contain_exec("rvm-system-user-#{username}").with_command("/usr/sbin/usermod -a -G #{group} #{username}") }
  end
end
