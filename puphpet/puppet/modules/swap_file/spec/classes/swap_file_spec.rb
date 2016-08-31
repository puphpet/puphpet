require 'spec_helper'

describe 'swap_file' do

  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "swap_file class without any parameters on #{osfamily}" do
        let(:facts) {{
          :osfamily => osfamily, :memorysize => '1 GB',
        }}

        it { should compile.with_all_deps }

        it { should contain_class('Swap_file::Params') }
        it { should contain_class('Swap_file') }

        it {
            should contain_exec('Create swap file').
              with_command('/bin/dd if=/dev/zero of=/mnt/swap.1 bs=1M count=1073')
            }

        it { should contain_exec('Attach swap file') }
      end
      describe "swap_file class with parameters on #{osfamily}" do
        let(:params) {{ :swapfile => '/foo/bar', :swapfilesize => '1 GB' }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('Swap_file::Params') }
        it { should contain_class('Swap_file') }

        it {
            should contain_exec('Create swap file').
              with_command('/bin/dd if=/dev/zero of=/foo/bar bs=1M count=1073')
            }
        it { should contain_exec('Attach swap file') }
      end
    end
  end

  context 'not officially support operating system' do
    describe 'Solaris Nexenta system without any parameters' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
        :memorysize      => '1 GB',
      }}

      it { should compile.with_all_deps }

      it { should contain_class('Swap_file::Params') }
      it { should contain_class('Swap_file') }

      it {
          should contain_exec('Create swap file').
            with_command('/bin/dd if=/dev/zero of=/mnt/swap.1 bs=1M count=1073')
          }

      it { should contain_exec('Attach swap file') }
    end
  end

  context 'windows operating system' do
    describe 'swap_file class without any parameters on Windows' do
      let(:facts) {{
        :osfamily        => 'windows',
        :operatingsystem => 'windows',
      }}

      it { expect { should contain_class('swap_file') }.to raise_error(Puppet::Error, /Swap files dont work on windows/) }
    end
  end
end
