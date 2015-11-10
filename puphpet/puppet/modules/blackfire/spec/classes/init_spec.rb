require 'spec_helper'
describe 'blackfire' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'fail with defaults for all parameters' do
        it do
          expect {
            should compile
          }.to raise_error(/server_id and server_token are required./)
        end
      end

      context 'with minimum set of parameters' do
        let(:params) do
          {
              :server_id => 'foo',
              :server_token => 'bar'
          }
        end

        it { should compile }
        it { should contain_class('blackfire') }
        it { should contain_class('blackfire::repo') }
        it { should contain_class('blackfire::agent') }
        it { should contain_class('blackfire::php') }
      end

    end
  end

end
