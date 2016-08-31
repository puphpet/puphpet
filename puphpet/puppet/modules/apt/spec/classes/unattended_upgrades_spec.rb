require 'spec_helper'
describe 'apt::unattended_upgrades', :type => :class do
  let(:file_unattended) { '/etc/apt/apt.conf.d/50unattended-upgrades' }
  let(:file_periodic) { '/etc/apt/apt.conf.d/10periodic' }
  let(:facts) { { :lsbdistid => 'Debian' } }

  it { should contain_package("unattended-upgrades") }

  it {
    should create_file("/etc/apt/apt.conf.d/50unattended-upgrades").with({
      "owner"   => "root",
      "group"   => "root",
      "mode"    => "0644",
      "require" => "Package[unattended-upgrades]",
    })
  }

  it {
    should create_file("/etc/apt/apt.conf.d/10periodic").with({
      "owner"   => "root",
      "group"   => "root",
      "mode"    => "0644",
      "require" => "Package[unattended-upgrades]",
    })
  }

  describe 'failing' do
    let :facts do
      {
        'lsbdistid'       => 'debian',
        'lsbdistcodename' => 'squeeze',
      }
    end
    context 'bad auto_fix' do
      let :params do
        {
          'auto_fix' => 'foo',
        }
      end
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'bad minimal_steps' do
      let :params do
        {
          'minimal_steps' => 'foo',
        }
      end
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'bad install_on_shutdown' do
      let :params do
        {
          'install_on_shutdown' => 'foo',
        }
      end
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'bad mail_only_on_error' do
      let :params do
        {
          'mail_only_on_error' => 'foo',
        }
      end
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'bad remove_unused' do
      let :params do
        {
          'remove_unused' => 'foo',
        }
      end
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'bad auto_reboot' do
      let :params do
        {
          'auto_reboot' => 'foo',
        }
      end
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'bad origins' do
      let :params do
        {
          'origins' => 'foo'
        }
      end
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'bad randomsleep' do
      let :params do
        {
          'randomsleep' => '4ever'
        }
      end
      it { expect { should raise_error(Puppet::Error) } }
    end
  end

  context 'defaults' do
    let :facts do
      {
        'lsbdistid'       => 'debian',
        'lsbdistcodename' => 'squeeze',
      }
    end

    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::Allowed-Origins \{\n\t"\${distro_id} oldstable";\n\t"\${distro_id} \${distro_codename}-security";\n\t"\${distro_id} \${distro_codename}-lts";\n\};} }
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::AutoFixInterruptedDpkg "true";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::MinimalSteps "false";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::InstallOnShutdown "false";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::Remove-Unused-Dependencies "true";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::Automatic-Reboot "false";}}

    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::Enable "1";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::BackUpArchiveInterval "0";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::BackUpLevel "3";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::MaxAge "0";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::MinAge "0";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::MaxSize "0";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::Update-Package-Lists "1";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::Download-Upgradeable-Packages "1";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::Download-Upgradeable-Packages-Debdelta "0";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::Unattended-Upgrade "1";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::AutocleanInterval "7";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::Verbose "0";}}
    it { is_expected.to_not contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::RandomSleep}}
  end

  context 'wheezy' do
    let :facts do
      {
        'lsbdistid'       => 'debian',
        'lsbdistcodename' => 'wheezy',
      }
    end

    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::Origins-Pattern \{\n\t"origin=Debian,archive=stable,label=Debian-Security";\n\t"origin=Debian,archive=oldstable,label=Debian-Security";\n\};} }
  end

  context 'anything but defaults' do
    let :facts do
      {
        'lsbdistid'       => 'debian',
        'lsbdistcodename' => 'wheezy',
      }
    end

    let :params do
      {
        'legacy_origin'       => true,
        'enable'              => '0',
        'backup_interval'     => '3',
        'backup_level'        => '1',
        'max_age'             => '7',
        'min_age'             => '1',
        'max_size'            => '100',
        'update'              => '0',
        'download'            => '0',
        'download_delta'      => '1',
        'upgrade'             => '0',
        'autoclean'           => '0',
        'verbose'             => '1',
        'origins'             => ['bananas'],
        'blacklist'           => ['foo', 'bar'],
        'auto_fix'            => false,
        'minimal_steps'       => true,
        'install_on_shutdown' => true,
        'mail_to'             => 'root@localhost',
        'mail_only_on_error'  => true,
        'remove_unused'       => false,
        'auto_reboot'         => true,
        'dl_limit'            => '70',
        'randomsleep'         => '1799',
      }
    end

    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::Allowed-Origins \{\n\t"bananas";\n\};} }
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::Package-Blacklist \{\n\t"foo";\n\t"bar";\n\};} }
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::AutoFixInterruptedDpkg "false";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::MinimalSteps "true";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::InstallOnShutdown "true";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::Mail "root@localhost";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::MailOnlyOnError "true";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::Remove-Unused-Dependencies "false";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Unattended-Upgrade::Automatic-Reboot "true";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/50unattended-upgrades").with_content %r{Acquire::http::Dl-Limit "70";}}

    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::Enable "0";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::BackUpArchiveInterval "3";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::BackUpLevel "1";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::MaxAge "7";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::MinAge "1";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::MaxSize "100";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::Update-Package-Lists "0";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::Download-Upgradeable-Packages "0";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::Download-Upgradeable-Packages-Debdelta "1";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::Unattended-Upgrade "0";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::AutocleanInterval "0";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::Verbose "1";}}
    it { is_expected.to contain_file("/etc/apt/apt.conf.d/10periodic").with_content %r{APT::Periodic::RandomSleep "1799";}}

  end
end
