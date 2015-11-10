require 'spec_helper'
require 'classes/shared_gpgkey'
require 'classes/shared_base'
require 'classes/shared_source'
require 'classes/shared_debuginfo'
require 'classes/shared_testing'
require 'classes/shared_testing_source'
require 'classes/shared_testing_debuginfo'

describe 'epel' do
  it { should create_class('epel') }
  it { should contain_class('epel::params') }

  context "operatingsystem => #{default_facts[:operatingsystem]}" do
    context 'operatingsystemmajrelease => 7' do
      let :facts do
        default_facts.merge({
          :operatingsystemrelease     => '7.0.1406',
          :operatingsystemmajrelease  => '7',
        })
      end

      it_behaves_like :base_7
      it_behaves_like :gpgkey_7
      it_behaves_like :epel_source_7
      it_behaves_like :epel_debuginfo_7
      it_behaves_like :epel_testing_7
      it_behaves_like :epel_testing_source_7
      it_behaves_like :epel_testing_debuginfo_7

      context 'epel_baseurl => http://example.com/epel/7/x87_74' do
        let(:params) {{ :epel_baseurl => "http://example.com/epel/7/x87_74" }}
        it { should contain_yumrepo('epel').with('baseurl'  => 'http://example.com/epel/7/x87_74') }
      end
      
      context 'epel_mirrorlist => absent' do
        let(:params) {{ :epel_mirrorlist => 'absent' }}
        it { should contain_yumrepo('epel').with('mirrorlist'  => 'absent') }
      end

      context 'operatingsystemmajrelease undef' do
        let :facts do
          default_facts.merge({
            :operatingsystemrelease => '7.0.1406',
          })
        end

        it_behaves_like :base_7
        it_behaves_like :gpgkey_7
        it_behaves_like :epel_source_7
        it_behaves_like :epel_debuginfo_7
        it_behaves_like :epel_testing_7
        it_behaves_like :epel_testing_source_7
        it_behaves_like :epel_testing_debuginfo_7
      end
    end

    context 'operatingsystemmajrelease => 6' do
      let :facts do
        default_facts.merge({
          :operatingsystemrelease     => '6.4',
          :operatingsystemmajrelease  => '6',
        })
      end

      it_behaves_like :base_6
      it_behaves_like :gpgkey_6
      it_behaves_like :epel_source_6
      it_behaves_like :epel_debuginfo_6
      it_behaves_like :epel_testing_6
      it_behaves_like :epel_testing_source_6
      it_behaves_like :epel_testing_debuginfo_6

      context 'epel_baseurl => http://example.com/epel/6/x86_64' do
        let(:params) {{ :epel_baseurl => "http://example.com/epel/6/x86_64" }}
        it { should contain_yumrepo('epel').with('baseurl'  => 'http://example.com/epel/6/x86_64') }
      end
      
      context 'epel_mirrorlist => absent' do
        let(:params) {{ :epel_mirrorlist => 'absent' }}
        it { should contain_yumrepo('epel').with('mirrorlist'  => 'absent') }
      end

      context 'operatingsystemmajrelease undef' do
        let :facts do
          default_facts.merge({
            :operatingsystemrelease => '6.4',
          })
        end

        it_behaves_like :base_6
        it_behaves_like :gpgkey_6
        it_behaves_like :epel_source_6
        it_behaves_like :epel_debuginfo_6
        it_behaves_like :epel_testing_6
        it_behaves_like :epel_testing_source_6
        it_behaves_like :epel_testing_debuginfo_6
      end
    end

    context 'operatingsystemmajrelease => 5' do
      let :facts do
        default_facts.merge({
          :operatingsystemrelease     => '5.9',
          :operatingsystemmajrelease  => '5',
        })
      end

      it_behaves_like :base_5
      it_behaves_like :gpgkey_5
      it_behaves_like :epel_source_5
      it_behaves_like :epel_debuginfo_5
      it_behaves_like :epel_testing_5
      it_behaves_like :epel_testing_source_5
      it_behaves_like :epel_testing_debuginfo_5
    end
  end

  context 'operatingsystem => Amazon' do
    let :facts do
      default_facts.merge({
        :operatingsystem  => 'Amazon',
      })
    end

    it { should_not contain_yumrepo('epel-testing') }
    it { should_not contain_yumrepo('epel-testing-debuginfo') }
    it { should_not contain_yumrepo('epel-testing-source') }
    it { should_not contain_yumrepo('epel-debuginfo') }
    it { should_not contain_yumrepo('epel-source') }

    it do
      should contain_yumrepo('epel').with({
        'enabled'   => '1',
        'gpgcheck'  => '1',
      })
    end
  end
end
