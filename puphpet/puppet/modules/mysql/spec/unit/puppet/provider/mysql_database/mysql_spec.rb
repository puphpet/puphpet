require 'spec_helper'

describe Puppet::Type.type(:mysql_database).provider(:mysql) do

  let(:defaults_file) { '--defaults-extra-file=/root/.my.cnf' }

  let(:raw_databases) do
    <<-SQL_OUTPUT
information_schema
mydb
mysql
performance_schema
test
    SQL_OUTPUT
  end

  let(:parsed_databases) { %w(information_schema mydb mysql performance_schema test) }

  let(:resource) { Puppet::Type.type(:mysql_database).new(
    { :ensure   => :present,
      :charset  => 'latin1',
      :collate  => 'latin1_swedish_ci',
      :name     => 'new_database',
      :provider => described_class.name
    }
  )}
  let(:provider) { resource.provider }

  before :each do
    Facter.stubs(:value).with(:root_home).returns('/root')
    Puppet::Util.stubs(:which).with('mysql').returns('/usr/bin/mysql')
    File.stubs(:file?).with('/root/.my.cnf').returns(true)
    provider.class.stubs(:mysql).with([defaults_file, '-NBe', 'show databases']).returns('new_database')
    provider.class.stubs(:mysql).with([defaults_file, '-NBe', "show variables like '%_database'", 'new_database']).returns("character_set_database latin1\ncollation_database latin1_swedish_ci\nskip_show_database OFF")
  end

  let(:instance) { provider.class.instances.first }

  describe 'self.instances' do
    it 'returns an array of databases' do
      provider.class.stubs(:mysql).with([defaults_file, '-NBe', 'show databases']).returns(raw_databases)
      raw_databases.each_line do |db|
        provider.class.stubs(:mysql).with([defaults_file, '-NBe', "show variables like '%_database'", db.chomp]).returns("character_set_database latin1\ncollation_database  latin1_swedish_ci\nskip_show_database  OFF")
      end
      databases = provider.class.instances.collect {|x| x.name }
      expect(parsed_databases).to match_array(databases)
    end
  end

  describe 'self.prefetch' do
    it 'exists' do
      provider.class.instances
      provider.class.prefetch({})
    end
  end

  describe 'create' do
    it 'makes a database' do
      provider.expects(:mysql).with([defaults_file, '-NBe', "create database if not exists `#{resource[:name]}` character set `#{resource[:charset]}` collate `#{resource[:collate]}`"])
      provider.expects(:exists?).returns(true)
      expect(provider.create).to be_truthy
    end
  end

  describe 'destroy' do
    it 'removes a database if present' do
      provider.expects(:mysql).with([defaults_file, '-NBe', "drop database if exists `#{resource[:name]}`"])
      provider.expects(:exists?).returns(false)
      expect(provider.destroy).to be_truthy
    end
  end

  describe 'exists?' do
    it 'checks if database exists' do
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

  describe 'charset' do
    it 'returns a charset' do
      expect(instance.charset).to eq('latin1')
    end
  end

  describe 'charset=' do
    it 'changes the charset' do
      provider.expects(:mysql).with([defaults_file, '-NBe', "alter database `#{resource[:name]}` CHARACTER SET blah"]).returns('0')

      provider.charset=('blah')
    end
  end

  describe 'collate' do
    it 'returns a collate' do
      expect(instance.collate).to eq('latin1_swedish_ci')
    end
  end

  describe 'collate=' do
    it 'changes the collate' do
      provider.expects(:mysql).with([defaults_file, '-NBe', "alter database `#{resource[:name]}` COLLATE blah"]).returns('0')

      provider.collate=('blah')
    end
  end

end
