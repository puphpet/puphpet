require 'spec_helper'

describe 'rvm::dependencies' do

  packages = ['which','gcc','autoconf','libcurl-devel','build-essential']

  let(:facts) {{}}

  shared_examples 'package creation' do |packages_to_have|
    packages_to_have.each {|p| it { should contain_package(p)} }
    (packages-packages_to_have).each {|p| it { should_not contain_package(p)} }
  end

  shared_context 'redhat_facts' do |operatingsystem, operatingsystemrelease|
    let(:facts) { super().merge({
      :osfamily => "RedHat",
      :operatingsystem => operatingsystem,
      :operatingsystemrelease => operatingsystemrelease
    }) }
  end

  shared_examples 'redhat' do |packages_to_have|
    it_behaves_like 'package creation', packages_to_have + ['which','gcc']
  end

  shared_examples 'redhat5' do |operatingsystem, operatingsystemrelease|
    include_context 'redhat_facts', operatingsystem, operatingsystemrelease
    it_behaves_like 'redhat', ['autoconf']
  end

  shared_examples 'redhat6' do |operatingsystem, operatingsystemrelease|
    include_context 'redhat_facts', operatingsystem, operatingsystemrelease
    it_behaves_like 'redhat', ['libcurl-devel']
  end

  shared_examples 'debian' do |operatingsystem|
    let(:facts) {{
      :osfamily => "Debian",
      :operatingsystem => operatingsystem
    }}
    it_behaves_like 'package creation', ['autoconf','build-essential']
  end


  context 'RedHat' do
    operatingsystems = ['centos', 'fedora', 'rhel', 'redhat', 'scientific']
    versions = { '5.0' => 'redhat5', '6.4' => 'redhat6' }
    operatingsystems.each do |os|
      context os, :compile do
        versions.each {|version,example| it_behaves_like example, os, version }
      end
    end

    context 'amazon linux', :compile do
      let(:facts) {{ :operatingsystemmajrelease => "3" }}
      it_behaves_like 'redhat6', 'Amazon', '3.4.43-43.43.amzn1.x86_64'
    end
  end

  context 'debian', :compile do
    it_behaves_like 'debian', 'ubuntu'
  end

  context 'other', :compile do
    let(:facts) {{ :operatingsystem => 'xxx' }}
    it_behaves_like 'package creation', []
  end
end
