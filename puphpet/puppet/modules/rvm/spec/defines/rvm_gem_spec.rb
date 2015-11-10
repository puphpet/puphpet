require 'spec_helper'

describe 'rvm_gem' do

  let(:title) { 'thin' }
  let(:params) {{ :ruby_version => '2.0' }}
  let(:pre_condition) { "rvm_system_ruby { '2.0': }" }

  context "when using default parameters", :compile do
    # TODO test autorequirement
    it { should contain_rvm_gem('thin') } #.that_requires("Rvm_system_ruby[2.0]")
  end
end
