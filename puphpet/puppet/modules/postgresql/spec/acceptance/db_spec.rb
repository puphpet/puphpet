require 'spec_helper_acceptance'

describe 'postgresql::server::db', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'creates a database' do
    begin
      tmpdir = default.tmpdir('postgresql')
      pp = <<-EOS
        class { 'postgresql::server': }
        postgresql::server::tablespace { 'postgresql_test_db':
          location => '#{tmpdir}',
        } ->
        postgresql::server::db { 'postgresql_test_db':
          comment    => 'testcomment',
          user       => 'test',
          password   => 'test1',
          tablespace => 'postgresql_test_db',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)

      psql('--command="select datname from pg_database" postgresql_test_db') do |r|
        expect(r.stdout).to match(/postgresql_test_db/)
        expect(r.stderr).to eq('')
      end

      psql('--command="SELECT 1 FROM pg_roles WHERE rolname=\'test\'"') do |r|
        expect(r.stdout).to match(/\(1 row\)/)
      end

      result = shell('psql --version')
      version = result.stdout.match(%r{\s(\d\.\d)})[1]
      if version > "8.1"
        comment_information_function = "shobj_description"
      else
        comment_information_function = "obj_description"
      end
      psql("--dbname postgresql_test_db --command=\"SELECT pg_catalog.#{comment_information_function}(d.oid, 'pg_database') FROM pg_catalog.pg_database d WHERE datname = 'postgresql_test_db' AND pg_catalog.#{comment_information_function}(d.oid, 'pg_database') = 'testcomment'\"") do |r|
        expect(r.stdout).to match(/\(1 row\)/)
      end
    ensure
      psql('--command="drop database postgresql_test_db" postgres')
      psql('--command="DROP USER test"')
    end
  end
end
