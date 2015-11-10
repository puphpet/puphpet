require 'spec_helper'

describe Puppet::Type.type(:postgresql_psql).provider(:ruby) do
  let(:name) { 'rspec psql test' }
  let(:resource) do
    Puppet::Type.type(:postgresql_psql).new({ :name => name, :provider => :ruby }.merge attributes)
  end

  let(:provider) { resource.provider }

  context("#run_sql_command") do
    describe "with default attributes" do
      let(:attributes) do { :db => 'spec_db' } end

      it "executes with the given psql_path on the given DB" do
        expect(provider).to receive(:run_command).with(['psql', '-d',
          attributes[:db], '-t', '-c', 'SELECT something'], 'postgres',
          'postgres')

        provider.run_sql_command("SELECT something")
      end
    end
    describe "with psql_path and db" do
      let(:attributes) do {
        :psql_path  => '/opt/postgres/psql',
        :psql_user  => 'spec_user',
        :psql_group => 'spec_group',
        :cwd        => '/spec',
        :db         => 'spec_db'
      } end

      it "executes with the given psql_path on the given DB" do
        expect(Dir).to receive(:chdir).with(attributes[:cwd]).and_yield
        expect(provider).to receive(:run_command).with([attributes[:psql_path],
          '-d', attributes[:db], '-t', '-c', 'SELECT something'],
          attributes[:psql_user], attributes[:psql_group])

        provider.run_sql_command("SELECT something")
      end
    end
    describe "with search_path string" do
      let(:attributes) do {
        :search_path => "schema1"
      } end

      it "executes with the given search_path" do
        expect(provider).to receive(:run_command).with(['psql', '-t', '-c',
          'set search_path to schema1; SELECT something'],
          'postgres', 'postgres')

        provider.run_sql_command("SELECT something")
      end
    end
    describe "with search_path array" do
      let(:attributes) do {
        :search_path => ['schema1','schema2'],
      } end

      it "executes with the given search_path" do
        expect(provider).to receive(:run_command).with(['psql', '-t', '-c',
          'set search_path to schema1,schema2; SELECT something'],
          'postgres',
          'postgres'
        )

        provider.run_sql_command("SELECT something")
      end
    end
  end
   describe "with port string" do
      let(:attributes) do { :port => '5555' } end

      it "executes with the given port" do
        expect(provider).to receive(:run_command).with(["psql",
        "-p", "5555",
        "-t", "-c", "SELECT something"],
        "postgres", "postgres")

        provider.run_sql_command("SELECT something")
      end
    end

  context("#run_unless_sql_command") do
    let(:attributes) do { } end

    it "calls #run_sql_command with SQL" do
      expect(provider).to receive(:run_sql_command).with('SELECT COUNT(*) FROM (SELECT 1) count')
      provider.run_unless_sql_command('SELECT 1')
    end
  end
end
