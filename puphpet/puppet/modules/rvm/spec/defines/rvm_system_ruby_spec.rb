require 'spec_helper'

describe 'rvm_system_ruby' do

  let(:title) { '2.0' }

  context "when using default parameters", :compile do
    it { should contain_rvm_system_ruby('2.0') }
  end
end
