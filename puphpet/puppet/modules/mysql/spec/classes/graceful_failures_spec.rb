require 'spec_helper'

describe 'mysql::server' do
  on_pe_unsupported_platforms.each do |pe_version,pe_platforms|
    pe_platforms.each do |pe_platform,facts|
      describe "on #{pe_version} #{pe_platform}" do
        let(:facts) { facts }

        context 'should gracefully fail' do
          it { expect { is_expected.to compile}.to raise_error(Puppet::Error, /Unsupported platform:/) }
        end
      end
    end
  end
end
