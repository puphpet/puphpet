require 'spec_helper_acceptance'

PUPPETLABS_GPG_KEY_SHORT_ID    = '4BD6EC30'
PUPPETLABS_GPG_KEY_LONG_ID     = '1054B7A24BD6EC30'
PUPPETLABS_GPG_KEY_FINGERPRINT = '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30'
PUPPETLABS_APT_URL             = 'apt.puppetlabs.com'
PUPPETLABS_GPG_KEY_FILE        = 'pubkey.gpg'
CENTOS_GPG_KEY_SHORT_ID        = 'C105B9DE'
CENTOS_GPG_KEY_LONG_ID         = '0946FCA2C105B9DE'
CENTOS_GPG_KEY_FINGERPRINT     = 'C1DAC52D1664E8A4386DBA430946FCA2C105B9DE'
CENTOS_REPO_URL                = 'ftp.cvut.cz/centos'
CENTOS_GPG_KEY_FILE            = 'RPM-GPG-KEY-CentOS-6'

SHOULD_NEVER_EXIST_ID          = '4BD6EC30'

KEY_CHECK_COMMAND              = "apt-key adv --list-keys --with-colons --fingerprint | grep "
PUPPETLABS_KEY_CHECK_COMMAND   = "#{KEY_CHECK_COMMAND} #{PUPPETLABS_GPG_KEY_FINGERPRINT}"
CENTOS_KEY_CHECK_COMMAND       = "#{KEY_CHECK_COMMAND} #{CENTOS_GPG_KEY_FINGERPRINT}"

describe 'apt_key' do
  before(:each) do
    # Delete twice to make sure everything is cleaned
    # up after the short key collision
    shell("apt-key del #{PUPPETLABS_GPG_KEY_SHORT_ID}",
          :acceptable_exit_codes => [0,1,2])
    shell("apt-key del #{PUPPETLABS_GPG_KEY_SHORT_ID}",
          :acceptable_exit_codes => [0,1,2])
  end

  describe 'default options' do
    key_versions = {
      '32bit key id'                        => '4BD6EC30',
      '64bit key id'                        => '1054B7A24BD6EC30',
      '160bit key fingerprint'              => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
      '32bit lowercase key id'              => '4bd6ec30',
      '64bit lowercase key id'              => '1054b7a24bd6ec30',
      '160bit lowercase key fingerprint'    => '47b320eb4c7c375aa9dae1a01054b7a24bd6ec30',
      '0x formatted 32bit key id'           => '0x4BD6EC30',
      '0x formatted 64bit key id'           => '0x1054B7A24BD6EC30',
      '0x formatted 160bit key fingerprint' => '0x47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
      '0x formatted 32bit lowercase key id' => '0x4bd6ec30',
      '0x formatted 64bit lowercase key id' => '0x1054b7a24bd6ec30',
      '0x formatted 160bit lowercase key fingerprint' => '0x47b320eb4c7c375aa9dae1a01054b7a24bd6ec30',
    }

    key_versions.each do |key, value|
      context "#{key}" do
        it 'works' do
          pp = <<-EOS
          apt_key { 'puppetlabs':
            id     => '#{value}',
            ensure => 'present',
          }
          EOS

          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes => true)
          shell(PUPPETLABS_KEY_CHECK_COMMAND)
        end
      end
    end

    context 'invalid length key id' do
      it 'fails' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id => '4B7A24BD6EC30',
        }
        EOS

        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/Valid values match/)
        end
      end
    end
  end

  describe 'ensure =>' do
    context 'absent' do
      it 'is removed' do
        pp = <<-EOS
        apt_key { 'centos':
          id     => '#{CENTOS_GPG_KEY_LONG_ID}',
          ensure => 'absent',
        }
        EOS

        # Install the key first
        shell("apt-key adv --keyserver keyserver.ubuntu.com \
              --recv-keys #{CENTOS_GPG_KEY_FINGERPRINT}")
        shell(CENTOS_KEY_CHECK_COMMAND)

        # Time to remove it using Puppet
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_failures => true)

        shell(CENTOS_KEY_CHECK_COMMAND,
              :acceptable_exit_codes => [1])

        shell("apt-key adv --keyserver keyserver.ubuntu.com \
              --recv-keys #{CENTOS_GPG_KEY_FINGERPRINT}")
      end
    end

    context 'absent, added with long key', :unless => (fact('operatingsystem') == 'Debian' and fact('operatingsystemmajrelease') == '6') do
      it 'is removed' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '#{PUPPETLABS_GPG_KEY_LONG_ID}',
          ensure => 'absent',
        }
        EOS

        # Install the key first
        shell("apt-key adv --keyserver keyserver.ubuntu.com \
              --recv-keys #{PUPPETLABS_GPG_KEY_LONG_ID}")
        shell(PUPPETLABS_KEY_CHECK_COMMAND)

        # Time to remove it using Puppet
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_failures => true)

        shell(PUPPETLABS_KEY_CHECK_COMMAND,
              :acceptable_exit_codes => [1])
      end
    end
  end

  describe 'content =>' do
    context 'puppetlabs gpg key' do
      it 'works' do
        pp = <<-EOS
          apt_key { 'puppetlabs':
            id      => '#{PUPPETLABS_GPG_KEY_FINGERPRINT}',
            ensure  => 'present',
            content => "-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: GPGTools - http://gpgtools.org

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
=a34C
-----END PGP PUBLIC KEY BLOCK-----",
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_failures => true)
        shell(PUPPETLABS_KEY_CHECK_COMMAND)
      end
    end

    context 'bogus key' do
      it 'fails' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id      => '#{PUPPETLABS_GPG_KEY_LONG_ID}',
          ensure  => 'present',
          content => 'For posterity: such content, much bogus, wow',
        }
        EOS

        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/no valid OpenPGP data found/)
        end
      end
    end
  end

  describe 'server =>' do
    context 'pgp.mit.edu' do
      it 'works' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '#{PUPPETLABS_GPG_KEY_LONG_ID}',
          ensure => 'present',
          server => 'pgp.mit.edu',
        }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_failures => true)
        shell(PUPPETLABS_KEY_CHECK_COMMAND)
      end
    end

    context 'hkp://pgp.mit.edu:80' do
      it 'works' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '#{PUPPETLABS_GPG_KEY_FINGERPRINT}',
          ensure => 'present',
          server => 'hkp://pgp.mit.edu:80',
        }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_failures => true)
        shell(PUPPETLABS_KEY_CHECK_COMMAND)
      end
    end

    context 'nonexistant.key.server' do
      it 'fails' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '#{PUPPETLABS_GPG_KEY_LONG_ID}',
          ensure => 'present',
          server => 'nonexistant.key.server',
        }
        EOS

        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/(Host not found|Couldn't resolve host)/)
        end
      end
    end

    context 'key server start with dot' do
      it 'fails' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '#{PUPPETLABS_GPG_KEY_LONG_ID}',
          ensure => 'present',
          server => '.pgp.key.server',
        }
        EOS

        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/Invalid value \".pgp.key.server\"/)
        end
      end
    end
  end

  describe 'source =>' do
    context 'http://' do
      it 'works' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '#{PUPPETLABS_GPG_KEY_LONG_ID}',
          ensure => 'present',
          source => 'http://#{PUPPETLABS_APT_URL}/#{PUPPETLABS_GPG_KEY_FILE}',
        }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_failures => true)
        shell(PUPPETLABS_KEY_CHECK_COMMAND)
      end

      it 'fails with a 404' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '#{PUPPETLABS_GPG_KEY_LONG_ID}',
          ensure => 'present',
          source => 'http://#{PUPPETLABS_APT_URL}/herpderp.gpg',
        }
        EOS

        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/404 Not Found/)
        end
      end

      it 'fails with a socket error' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '#{PUPPETLABS_GPG_KEY_LONG_ID}',
          ensure => 'present',
          source => 'http://apt.puppetlabss.com/herpderp.gpg',
        }
        EOS

        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/could not resolve/)
        end
      end
    end

    context 'ftp://' do
      before(:each) do
        shell("apt-key del #{CENTOS_GPG_KEY_LONG_ID}",
              :acceptable_exit_codes => [0,1,2])
      end

      it 'works' do
        pp = <<-EOS
        apt_key { 'CentOS 6':
          id     => '#{CENTOS_GPG_KEY_LONG_ID}',
          ensure => 'present',
          source => 'ftp://#{CENTOS_REPO_URL}/#{CENTOS_GPG_KEY_FILE}',
        }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_failures => true)
        shell(CENTOS_KEY_CHECK_COMMAND)
      end

      it 'fails with a 550' do
        pp = <<-EOS
        apt_key { 'CentOS 6':
          id     => '#{SHOULD_NEVER_EXIST_ID}',
          ensure => 'present',
          source => 'ftp://#{CENTOS_REPO_URL}/herpderp.gpg',
        }
        EOS

        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/550 Failed to open/)
        end
      end

      it 'fails with a socket error' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '#{PUPPETLABS_GPG_KEY_LONG_ID}',
          ensure => 'present',
          source => 'ftp://apt.puppetlabss.com/herpderp.gpg',
        }
        EOS

        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/could not resolve/)
        end
      end
    end

    context 'https://' do
      it 'works' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '#{PUPPETLABS_GPG_KEY_LONG_ID}',
          ensure => 'present',
          source => 'https://#{PUPPETLABS_APT_URL}/#{PUPPETLABS_GPG_KEY_FILE}',
        }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_failures => true)
        shell(PUPPETLABS_KEY_CHECK_COMMAND)
      end

      it 'fails with a 404' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '#{SHOULD_NEVER_EXIST_ID}',
          ensure => 'present',
          source => 'https://#{PUPPETLABS_APT_URL}/herpderp.gpg',
        }
        EOS

        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/404 Not Found/)
        end
      end

      it 'fails with a socket error' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '#{SHOULD_NEVER_EXIST_ID}',
          ensure => 'present',
          source => 'https://apt.puppetlabss.com/herpderp.gpg',
        }
        EOS

        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/could not resolve/)
        end
      end
    end

    context '/path/that/exists' do
      before(:each) do
        shell("curl -o /tmp/puppetlabs-pubkey.gpg \
              http://#{PUPPETLABS_APT_URL}/#{PUPPETLABS_GPG_KEY_FILE}")
      end

      after(:each) do
        shell('rm /tmp/puppetlabs-pubkey.gpg')
      end

      it 'works' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '4BD6EC30',
          ensure => 'present',
          source => '/tmp/puppetlabs-pubkey.gpg',
        }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_failures => true)
        shell(PUPPETLABS_KEY_CHECK_COMMAND)
      end
    end

    context '/path/that/does/not/exist' do
      it 'fails' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '#{PUPPETLABS_GPG_KEY_LONG_ID}',
          ensure => 'present',
          source => '/tmp/totally_bogus.file',
        }
        EOS

        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/does not exist/)
        end
      end
    end

    context '/path/that/exists/with/bogus/content' do
      before(:each) do
        shell('echo "here be dragons" > /tmp/fake-key.gpg')
      end

      after(:each) do
        shell('rm /tmp/fake-key.gpg')
      end
      it 'fails' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id     => '#{PUPPETLABS_GPG_KEY_LONG_ID}',
          ensure => 'present',
          source => '/tmp/fake-key.gpg',
        }
        EOS

        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/no valid OpenPGP data found/)
        end
      end
    end
  end

  describe 'keyserver_options =>' do
    context 'debug' do
      it 'works' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id                => '#{PUPPETLABS_GPG_KEY_LONG_ID}',
          ensure            => 'present',
          keyserver_options => 'debug',
        }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_failures => true)
        shell(PUPPETLABS_KEY_CHECK_COMMAND)
      end

      it 'fails on invalid options' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id                => '#{PUPPETLABS_GPG_KEY_LONG_ID}',
          ensure            => 'present',
          keyserver_options => 'this is totally bonkers',
        }
        EOS

        shell("apt-key del #{PUPPETLABS_GPG_KEY_FINGERPRINT}", :acceptable_exit_codes => [0,1,2])
        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/--keyserver-options this is totally/)
        end
      end
    end
  end

  describe 'fingerprint validation against source/content' do
    context 'fingerprint in id matches fingerprint from remote key' do
      it 'works' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id      => '#{PUPPETLABS_GPG_KEY_FINGERPRINT}',
          ensure  => 'present',
          source  => 'https://#{PUPPETLABS_APT_URL}/#{PUPPETLABS_GPG_KEY_FILE}',
        }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_failures => true)
      end
    end

    context 'fingerprint in id does NOT match fingerprint from remote key' do
      it 'works' do
        pp = <<-EOS
        apt_key { 'puppetlabs':
          id      => '47B320EB4C7C375AA9DAE1A01054B7A24BD6E666',
          ensure  => 'present',
          source  => 'https://#{PUPPETLABS_APT_URL}/#{PUPPETLABS_GPG_KEY_FILE}',
        }
        EOS

        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/do not match/)
        end
      end
    end
  end

end
