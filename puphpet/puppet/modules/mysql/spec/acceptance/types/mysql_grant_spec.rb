require 'spec_helper_acceptance'

describe 'mysql_grant' do

  describe 'setup' do
    it 'setup mysql::server' do
      pp = <<-EOS
        class { 'mysql::server': }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
  end

  describe 'missing privileges for user' do
    it 'should fail' do
      pp = <<-EOS
        mysql_grant { 'test1@tester/test.*':
          ensure => 'present',
          table  => 'test.*',
          user   => 'test1@tester',
        }
      EOS

      expect(apply_manifest(pp, :expect_failures => true).stderr).to match(/privileges parameter is required/)
    end

    it 'should not find the user' do
      expect(shell("mysql -NBe \"SHOW GRANTS FOR test1@tester\"", { :acceptable_exit_codes => 1}).stderr).to match(/There is no such grant defined for user 'test1' on host 'tester'/)
    end
  end

  describe 'missing table for user' do
    it 'should fail' do
      pp = <<-EOS
        mysql_grant { 'atest@tester/test.*':
          ensure => 'present',
          user   => 'atest@tester',
          privileges => ['ALL'],
        }
      EOS

      apply_manifest(pp, :expect_failures => true)
    end

    it 'should not find the user' do
      expect(shell("mysql -NBe \"SHOW GRANTS FOR atest@tester\"", {:acceptable_exit_codes => 1}).stderr).to match(/There is no such grant defined for user 'atest' on host 'tester'/)
    end
  end

  describe 'adding privileges' do
    it 'should work without errors' do
      pp = <<-EOS
        mysql_grant { 'test2@tester/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test2@tester',
          privileges => ['SELECT', 'UPDATE'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    it 'should find the user' do
      shell("mysql -NBe \"SHOW GRANTS FOR test2@tester\"") do |r|
        expect(r.stdout).to match(/GRANT SELECT, UPDATE.*TO 'test2'@'tester'/)
        expect(r.stderr).to be_empty
      end
    end
  end

  describe 'adding privileges with special character in name' do
    it 'should work without errors' do
      pp = <<-EOS
        mysql_grant { 'test-2@tester/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test-2@tester',
          privileges => ['SELECT', 'UPDATE'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    it 'should find the user' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test-2'@tester\"") do |r|
        expect(r.stdout).to match(/GRANT SELECT, UPDATE.*TO 'test-2'@'tester'/)
        expect(r.stderr).to be_empty
      end
    end
  end

  describe 'adding privileges with invalid name' do
    it 'should fail' do
      pp = <<-EOS
        mysql_grant { 'test':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test2@tester',
          privileges => ['SELECT', 'UPDATE'],
        }
      EOS

      expect(apply_manifest(pp, :expect_failures => true).stderr).to match(/name must match user and table parameters/)
    end
  end

  describe 'adding option' do
    it 'should work without errors' do
      pp = <<-EOS
        mysql_grant { 'test3@tester/test.*':
          ensure  => 'present',
          table   => 'test.*',
          user    => 'test3@tester',
          options => ['GRANT'],
          privileges => ['SELECT', 'UPDATE'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    it 'should find the user' do
      shell("mysql -NBe \"SHOW GRANTS FOR test3@tester\"") do |r|
        expect(r.stdout).to match(/GRANT SELECT, UPDATE ON `test`.* TO 'test3'@'tester' WITH GRANT OPTION$/)
        expect(r.stderr).to be_empty
      end
    end
  end

  describe 'adding all privileges without table' do
    it 'should fail' do
      pp = <<-EOS
        mysql_grant { 'test4@tester/test.*':
          ensure     => 'present',
          user       => 'test4@tester',
          options    => ['GRANT'],
          privileges => ['SELECT', 'UPDATE', 'ALL'],
        }
      EOS

      expect(apply_manifest(pp, :expect_failures => true).stderr).to match(/table parameter is required./)
    end
  end

  describe 'adding all privileges' do
    it 'should only try to apply ALL' do
      pp = <<-EOS
        mysql_grant { 'test4@tester/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test4@tester',
          options    => ['GRANT'],
          privileges => ['SELECT', 'UPDATE', 'ALL'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    it 'should find the user' do
      shell("mysql -NBe \"SHOW GRANTS FOR test4@tester\"") do |r|
        expect(r.stdout).to match(/GRANT ALL PRIVILEGES ON `test`.* TO 'test4'@'tester' WITH GRANT OPTION/)
        expect(r.stderr).to be_empty
      end
    end
  end

  # Test combinations of user@host to ensure all cases work.
  describe 'short hostname' do
    it 'should apply' do
      pp = <<-EOS
        mysql_grant { 'test@short/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@short',
          privileges => 'ALL',
        }
        mysql_grant { 'test@long.hostname.com/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@long.hostname.com',
          privileges => 'ALL',
        }
        mysql_grant { 'test@192.168.5.6/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@192.168.5.6',
          privileges => 'ALL',
        }
        mysql_grant { 'test@2607:f0d0:1002:0051:0000:0000:0000:0004/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@2607:f0d0:1002:0051:0000:0000:0000:0004',
          privileges => 'ALL',
        }
        mysql_grant { 'test@::1/128/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@::1/128',
          privileges => 'ALL',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    it 'finds short hostname' do
      shell("mysql -NBe \"SHOW GRANTS FOR test@short\"") do |r|
        expect(r.stdout).to match(/GRANT ALL PRIVILEGES ON `test`.* TO 'test'@'short'/)
        expect(r.stderr).to be_empty
      end
    end
    it 'finds long hostname' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'long.hostname.com'\"") do |r|
        expect(r.stdout).to match(/GRANT ALL PRIVILEGES ON `test`.* TO 'test'@'long.hostname.com'/)
        expect(r.stderr).to be_empty
      end
    end
    it 'finds ipv4' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'192.168.5.6'\"") do |r|
        expect(r.stdout).to match(/GRANT ALL PRIVILEGES ON `test`.* TO 'test'@'192.168.5.6'/)
        expect(r.stderr).to be_empty
      end
    end
    it 'finds ipv6' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'2607:f0d0:1002:0051:0000:0000:0000:0004'\"") do |r|
        expect(r.stdout).to match(/GRANT ALL PRIVILEGES ON `test`.* TO 'test'@'2607:f0d0:1002:0051:0000:0000:0000:0004'/)
        expect(r.stderr).to be_empty
      end
    end
    it 'finds short ipv6' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'::1/128'\"") do |r|
        expect(r.stdout).to match(/GRANT ALL PRIVILEGES ON `test`.* TO 'test'@'::1\/128'/)
        expect(r.stderr).to be_empty
      end
    end
  end

  describe 'complex test' do
    it 'setup mysql::server' do
      pp = <<-EOS
      $dbSubnet = '10.10.10.%'

      mysql_database { 'foo':
        ensure => present,
      }

      exec { 'mysql-create-table':
        command     => '/usr/bin/mysql -NBe "CREATE TABLE foo.bar (name VARCHAR(20))"',
        environment => "HOME=${::root_home}",
        unless      => '/usr/bin/mysql -NBe "SELECT 1 FROM foo.bar LIMIT 1;"',
        require     => Mysql_database['foo'],
      }

      Mysql_grant {
          ensure     => present,
          options    => ['GRANT'],
          privileges => ['ALL'],
          table      => '*.*',
          require    => [ Mysql_database['foo'], Exec['mysql-create-table'] ],
      }

      mysql_grant { "user1@${dbSubnet}/*.*":
          user       => "user1@${dbSubnet}",
      }
      mysql_grant { "user2@${dbSubnet}/foo.bar":
          privileges => ['SELECT', 'INSERT', 'UPDATE'],
          user       => "user2@${dbSubnet}",
          table      => 'foo.bar',
      }
      mysql_grant { "user3@${dbSubnet}/foo.*":
          privileges => ['SELECT', 'INSERT', 'UPDATE'],
          user       => "user3@${dbSubnet}",
          table      => 'foo.*',
      }
      mysql_grant { 'web@%/*.*':
          user       => 'web@%',
      }
      mysql_grant { "web@${dbSubnet}/*.*":
          user       => "web@${dbSubnet}",
      }
      mysql_grant { "web@${fqdn}/*.*":
          user       => "web@${fqdn}",
      }
      mysql_grant { 'web@localhost/*.*':
          user       => 'web@localhost',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'lower case privileges' do
    it 'create ALL privs' do
      pp = <<-EOS
      mysql_grant { 'lowercase@localhost/*.*':
          user       => 'lowercase@localhost',
          privileges => 'ALL',
          table      => '*.*',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    it 'create lowercase all privs' do
      pp = <<-EOS
      mysql_grant { 'lowercase@localhost/*.*':
          user       => 'lowercase@localhost',
          privileges => 'all',
          table      => '*.*',
      }
      EOS

      expect(apply_manifest(pp, :catch_failures => true).exit_code).to eq(0)
    end
  end

  describe 'adding procedure privileges' do
    it 'should work without errors' do
       pp = <<-EOS
       mysql_grant { 'test2@tester/PROCEDURE test.simpleproc':
         ensure     => 'present',
         table      => 'PROCEDURE test.simpleproc',
         user       => 'test2@tester',
         privileges => ['EXECUTE'],
       }
       EOS

      apply_manifest(pp, :catch_failures => true)
    end

    it 'should find the user' do
      shell("mysql -NBe \"SHOW GRANTS FOR test2@tester\"") do |r|
        expect(r.stdout).to match(/GRANT EXECUTE ON PROCEDURE `test`.`simpleproc` TO 'test2'@'tester'/)
        expect(r.stderr).to be_empty
      end
    end
  end

  describe 'grants with skip-name-resolve specified' do
    it 'setup mysql::server' do
      pp = <<-EOS
        class { 'mysql::server':
          override_options => {
            'mysqld' => {'skip-name-resolve' => true}
          },
          restart          => true,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    it 'should apply' do
      pp = <<-EOS
        mysql_grant { 'test@fqdn.com/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@fqdn.com',
          privileges => 'ALL',
        }
        mysql_grant { 'test@192.168.5.7/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@192.168.5.7',
          privileges => 'ALL',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    it 'should fail with fqdn' do
      expect(shell("mysql -NBe \"SHOW GRANTS FOR test@fqdn.com\"", { :acceptable_exit_codes => 1}).stderr).to match(/There is no such grant defined for user 'test' on host 'fqdn.com'/)
    end
    it 'finds ipv4' do
      shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'192.168.5.7'\"") do |r|
        expect(r.stdout).to match(/GRANT ALL PRIVILEGES ON `test`.* TO 'test'@'192.168.5.7'/)
        expect(r.stderr).to be_empty
      end
    end

    it 'should fail to execute while applying' do
      pp = <<-EOS
        mysql_grant { 'test@fqdn.com/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@fqdn.com',
          privileges => 'ALL',
        }
      EOS

      mysql_cmd = shell('which mysql').stdout.chomp
      shell("mv #{mysql_cmd} #{mysql_cmd}.bak")
      expect(apply_manifest(pp, :expect_failures => true).stderr).to match(/Command mysql is missing/)
      shell("mv #{mysql_cmd}.bak #{mysql_cmd}")
    end

    it 'reset mysql::server config' do
      pp = <<-EOS
        class { 'mysql::server':
          restart          => true,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
  end

end
