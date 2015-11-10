require 'spec_helper_acceptance'

describe 'mysql::server::backup class' do
  context 'should work with no errors' do
    it 'when configuring mysql backups' do
      pp = <<-EOS
        class { 'mysql::server': root_password => 'password' }
        mysql::db { [
          'backup1',
          'backup2'
        ]:
          user     => 'backup',
          password => 'secret',
        }

        class { 'mysql::server::backup':
          backupuser     => 'myuser',
          backuppassword => 'mypassword',
          backupdir      => '/tmp/backups',
          backupcompress => true,
          postscript     => [
            'rm -rf /var/tmp/mysqlbackups',
            'rm -f /var/tmp/mysqlbackups.done',
            'cp -r /tmp/backups /var/tmp/mysqlbackups',
            'touch /var/tmp/mysqlbackups.done',
          ],
          execpath      => '/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_failures => true)
    end
  end

  describe 'mysqlbackup.sh' do
    it 'should run mysqlbackup.sh with no errors' do
      shell("/usr/local/sbin/mysqlbackup.sh") do |r|
        expect(r.stderr).to eq("")
      end
    end

    it 'should dump all databases to single file' do
      shell('ls -l /tmp/backups/mysql_backup_*-*.sql.bz2 | wc -l') do |r|
        expect(r.stdout).to match(/1/)
        expect(r.exit_code).to be_zero
      end
    end

    context 'should create one file per database per run' do
      it 'executes mysqlbackup.sh a second time' do
        shell('sleep 1')
        shell('/usr/local/sbin/mysqlbackup.sh')
      end

      it 'creates at least one backup tarball' do
        shell('ls -l /tmp/backups/mysql_backup_*-*.sql.bz2 | wc -l') do |r|
          expect(r.stdout).to match(/2/)
          expect(r.exit_code).to be_zero
        end
      end
    end
  end

  context 'with one file per database' do
    context 'should work with no errors' do
      it 'when configuring mysql backups' do
        pp = <<-EOS
          class { 'mysql::server': root_password => 'password' }
          mysql::db { [
            'backup1',
            'backup2'
          ]:
            user     => 'backup',
            password => 'secret',
          }

          class { 'mysql::server::backup':
            backupuser        => 'myuser',
            backuppassword    => 'mypassword',
            backupdir         => '/tmp/backups',
            backupcompress    => true,
            file_per_database => true,
            postscript        => [
              'rm -rf /var/tmp/mysqlbackups',
              'rm -f /var/tmp/mysqlbackups.done',
              'cp -r /tmp/backups /var/tmp/mysqlbackups',
              'touch /var/tmp/mysqlbackups.done',
            ],
            execpath          => '/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin',
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_failures => true)
      end
    end

    describe 'mysqlbackup.sh' do
      it 'should run mysqlbackup.sh with no errors without root credentials' do
        shell("HOME=/tmp/dontreadrootcredentials /usr/local/sbin/mysqlbackup.sh") do |r|
          expect(r.stderr).to eq("")
        end
      end

      it 'should create one file per database' do
        ['backup1', 'backup2'].each do |database|
          shell("ls -l /tmp/backups/mysql_backup_#{database}_*-*.sql.bz2 | wc -l") do |r|
            expect(r.stdout).to match(/1/)
            expect(r.exit_code).to be_zero
          end
        end
      end

      context 'should create one file per database per run' do
        it 'executes mysqlbackup.sh a second time' do
          shell('sleep 1')
          shell('HOME=/tmp/dontreadrootcredentials /usr/local/sbin/mysqlbackup.sh')
        end

        it 'has one file per database per run' do
          ['backup1', 'backup2'].each do |database|
            shell("ls -l /tmp/backups/mysql_backup_#{database}_*-*.sql.bz2 | wc -l") do |r|
              expect(r.stdout).to match(/2/)
              expect(r.exit_code).to be_zero
            end
          end
        end
      end
    end
  end
end
