require 'spec_helper_acceptance'

describe 'postgresql::server::schema:', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'should create a schema for a user' do
    begin
      pp = <<-EOS.unindent
        $db = 'schema_test'
        $user = 'psql_schema_tester'
        $password = 'psql_schema_pw'

        class { 'postgresql::server': }

        # Since we are not testing pg_hba or any of that, make a local user for ident auth
        user { $user:
          ensure => present,
        }

        postgresql::server::role { $user:
          password_hash => postgresql_password($user, $password),
        }

        postgresql::server::database { $db:
          owner   => $user,
          require => Postgresql::Server::Role[$user],
        }

        # Create a rule for the user
        postgresql::server::pg_hba_rule { "allow ${user}":
          type        => 'local',
          database    => $db,
          user        => $user,
          auth_method => 'ident',
          order       => 1,
        }

        postgresql::server::schema { $user:
          db      => $db,
          owner   => $user,
          require => Postgresql::Server::Database[$db],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)

      ## Check that the user can create a table in the database
      psql('--command="create table psql_schema_tester.foo (foo int)" schema_test', 'psql_schema_tester') do |r|
        expect(r.stdout).to match(/CREATE TABLE/)
        expect(r.stderr).to eq('')
      end
    ensure
      psql('--command="drop table psql_schema_tester.foo" schema_test', 'psql_schema_tester')
    end
  end

end
