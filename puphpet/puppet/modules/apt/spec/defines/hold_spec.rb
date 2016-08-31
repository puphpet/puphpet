require 'spec_helper'
describe 'apt::hold' do
  let :facts do {
    :osfamily   => 'Debian',
    :lsbdistid  => 'Debian',
    :lsbrelease => 'wheezy',
  } end

  let :title do
    'vim'
  end

  let :default_params do {
    :version => '1.1.1',
  } end

  describe 'default params' do
    let :params do default_params end

    it 'creates an apt preferences file' do
      should contain_apt__pin("hold_#{title}").with({
        :ensure   => 'present',
        :packages => title,
        :version  => params[:version],
        :priority => 1001,
      })
    end
  end

  describe 'ensure => absent' do
    let :params do default_params.merge({:ensure => 'absent',}) end

    it 'creates an apt preferences file' do

      should contain_apt__pin("hold_#{title}").with({
        :ensure   => params[:ensure],
      })
    end
  end

  describe 'priority => 990' do
    let :params do default_params.merge({:priority => 990,}) end

    it 'creates an apt preferences file' do
      should contain_apt__pin("hold_#{title}").with({
        :ensure   => 'present',
        :packages => title,
        :version  => params[:version],
        :priority => params[:priority],
      })
    end
  end

  describe 'package => foo' do
    let :params do default_params.merge({:package => 'foo'}) end

    it 'creates an apt preferences file' do
      should contain_apt__pin("hold_foo").with({
        :ensure   => 'present',
        :packages => 'foo',
        :version  => params[:version],
        :priority => 1001,
      })
    end
  end


  describe 'validation' do
    context 'version => {}' do
      let :params do { :version => {}, } end
      it 'should fail' do
        expect { subject }.to raise_error(/is not a string/)
      end
    end

    context 'ensure => bananana' do
      let :params do default_params.merge({:ensure => 'bananana',}) end
      it 'should fail' do
        expect { subject }.to raise_error(/does not match/)
      end
    end

    context 'package => []' do
      let :params do default_params.merge({:package => [],}) end
      it 'should fail' do
        expect { subject }.to raise_error(/is not a string/)
      end
    end

    context 'priority => bananana' do
      let :params do default_params.merge({:priority => 'bananana',}) end
      it 'should fail' do
        expect { subject }.to raise_error(/must be an integer/)
      end
    end
  end
end
