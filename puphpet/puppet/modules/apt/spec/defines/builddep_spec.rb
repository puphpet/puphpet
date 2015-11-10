require 'spec_helper'
describe 'apt::builddep', :type => :define do

  let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian' } }
  let(:title) { 'my_package' }

  describe "defaults" do
    it { should contain_exec("apt-builddep-my_package").that_requires('Exec[apt_update]').with({
        'command' => "/usr/bin/apt-get -y --force-yes build-dep my_package",
        'logoutput' => 'on_failure'
      })
    }
    it { should contain_anchor("apt::builddep::my_package").with({
        'require' => 'Class[Apt::Update]',
      })
    }
  end

end
