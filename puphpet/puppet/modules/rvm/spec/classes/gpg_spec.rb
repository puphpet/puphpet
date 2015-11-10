require 'spec_helper'

describe 'rvm::gpg' do

  context "RedHat", :compile do
    let(:facts) {{
      :kernel => 'Linux',
      :osfamily => 'RedHat'
    }}
    it { should contain_package('gnupg2') }
  end

  context "Debian", :compile do
    let(:facts) {{
      :kernel => 'Linux',
      :osfamily => 'Debian'
    }}
    it { should contain_package('gnupg2') }
  end

  context "OS X", :compile do
    let(:facts) {{
      :kernel => 'Darwin',
      :osfamily => 'Darwin'
    }}
    it { should contain_package('gnupg2') }
  end
end
