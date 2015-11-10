require 'spec_helper_acceptance'

describe 'postgresql_psql', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  it 'should always run SQL' do
    pp = <<-EOS
      class { 'postgresql::server': } ->
      postgresql_psql { 'foobar':
        db        => 'postgres',
        psql_user => 'postgres',
        command   => 'select 1',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :expect_changes => true)
  end

  it 'should run some SQL when the unless query returns no rows' do
    pp = <<-EOS
      class { 'postgresql::server': } ->
      postgresql_psql { 'foobar':
        db        => 'postgres',
        psql_user => 'postgres',
        command   => 'select 1',
        unless    => 'select 1 where 1=2',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :expect_changes  => true)
  end

  it 'should not run SQL when the unless query returns rows' do
    pp = <<-EOS
      class { 'postgresql::server': } ->
      postgresql_psql { 'foobar':
        db        => 'postgres',
        psql_user => 'postgres',
        command   => 'select * from pg_database limit 1',
        unless    => 'select 1 where 1=1',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  it 'should not run SQL when refreshed and the unless query returns rows' do
    pp = <<-EOS
      class { 'postgresql::server': } ->
      notify { 'trigger': } ~>
      postgresql_psql { 'foobar':
        db        => 'postgres',
        psql_user => 'postgres',
        command   => 'invalid sql statement',
        unless    => 'select 1 where 1=1',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :expect_changes => true)
  end

  context 'with refreshonly' do
    it 'should not run SQL when the unless query returns no rows' do
      pp = <<-EOS
        class { 'postgresql::server': } ->
        postgresql_psql { 'foobar':
          db          => 'postgres',
          psql_user   => 'postgres',
          command     => 'select 1',
          unless      => 'select 1 where 1=2',
          refreshonly => true,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    it 'should run SQL when refreshed and the unless query returns no rows' do
      pp = <<-EOS.unindent
        class { 'postgresql::server': } ->
        notify { 'trigger': } ~>
        postgresql_psql { 'foobar':
          db          => 'postgres',
          psql_user   => 'postgres',
          command     => 'select 1',
          unless      => 'select 1 where 1=2',
          refreshonly => true,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :expect_changes => true)
    end

    it 'should not run SQL when refreshed and the unless query returns rows' do
      pp = <<-EOS.unindent
        class { 'postgresql::server': } ->
        notify { 'trigger': } ~>
        postgresql_psql { 'foobar':
          db          => 'postgres',
          psql_user   => 'postgres',
          command     => 'invalid sql query',
          unless      => 'select 1 where 1=1',
          refreshonly => true,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :expect_changes => true)
    end
  end
end
