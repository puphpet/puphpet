require 'spec_helper'

describe Puppet::Type.type(:mysql_plugin).provider(:mysql) do

  let(:defaults_file) { '--defaults-extra-file=/root/.my.cnf' }

  let(:resource) { Puppet::Type.type(:mysql_plugin).new(
    { :ensure   => :present,
      :soname   => 'auth_socket.so',
      :name     => 'auth_socket',
      :provider => described_class.name
    }
  )}
  let(:provider) { resource.provider }

  before :each do
    Facter.stubs(:value).with(:root_home).returns('/root')
    Puppet::Util.stubs(:which).with('mysql').returns('/usr/bin/mysql')
    File.stubs(:file?).with('/root/.my.cnf').returns(true)
    provider.class.stubs(:mysql).with([defaults_file, '-NBe', 'show plugins']).returns('auth_socket	ACTIVE	AUTHENTICATION	auth_socket.so	GPL')
  end

  let(:instance) { provider.class.instances.first }

  describe 'self.prefetch' do
    it 'exists' do
      provider.class.instances
      provider.class.prefetch({})
    end
  end

  describe 'create' do
    it 'loads a plugin' do
      provider.expects(:mysql).with([defaults_file, '-NBe', "install plugin #{resource[:name]} soname '#{resource[:soname]}'"])
      provider.expects(:exists?).returns(true)
      expect(provider.create).to be_truthy
    end
  end

  describe 'destroy' do
    it 'unloads a plugin if present' do
      provider.expects(:mysql).with([defaults_file, '-NBe', "uninstall plugin #{resource[:name]}"])
      provider.expects(:exists?).returns(false)
      expect(provider.destroy).to be_truthy
    end
  end

  describe 'exists?' do
    it 'checks if plugin exists' do
      expect(instance.exists?).to be_truthy
    end
  end

  describe 'self.defaults_file' do
    it 'sets --defaults-extra-file' do
      File.stubs(:file?).with('/root/.my.cnf').returns(true)
      expect(provider.defaults_file).to eq '--defaults-extra-file=/root/.my.cnf'
    end
    it 'fails if file missing' do
      File.stubs(:file?).with('/root/.my.cnf').returns(false)
      expect(provider.defaults_file).to be_nil
    end
  end

  describe 'soname' do
    it 'returns a soname' do
      expect(instance.soname).to eq('auth_socket.so')
    end
  end

end
