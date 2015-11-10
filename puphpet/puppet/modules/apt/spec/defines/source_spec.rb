require 'spec_helper'

describe 'apt::source', :type => :define do
  GPG_KEY_ID = '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30'


  let :title do
    'my_source'
  end

  context 'mostly defaults' do
    let :facts do
      {
        :lsbdistid       => 'Debian',
        :lsbdistcodename => 'wheezy',
        :osfamily        => 'Debian'
      }
    end

    let :params do
      {
        'include_deb' => false,
      }
    end

    it { is_expected.to contain_file('my_source.list').that_notifies('Exec[apt_update]').with({
      'ensure' => 'present',
      'path'   => '/etc/apt/sources.list.d/my_source.list',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    }).with_content(/# my_source\ndeb-src  wheezy main\n/)
    }
  end

  context 'no defaults' do
    let :facts do
      {
        :lsbdistid       => 'Debian',
        :lsbdistcodename => 'wheezy',
        :osfamily        => 'Debian'
      }
    end
    let :params do
      {
        'comment'           => 'foo',
        'location'          => 'http://debian.mirror.iweb.ca/debian/',
        'release'           => 'sid',
        'repos'             => 'testing',
        'include_src'       => false,
        'required_packages' => 'vim',
        'key'               => GPG_KEY_ID,
        'key_server'        => 'pgp.mit.edu',
        'key_content'       => 'GPG key content',
        'key_source'        => 'http://apt.puppetlabs.com/pubkey.gpg',
        'pin'               => '10',
        'architecture'      => 'x86_64',
        'trusted_source'    => true,
      }
    end

    it { is_expected.to contain_file('my_source.list').that_notifies('Exec[apt_update]').with({
      'ensure' => 'present',
      'path'   => '/etc/apt/sources.list.d/my_source.list',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    }).with_content(/# foo\ndeb \[arch=x86_64 trusted=yes\] http:\/\/debian\.mirror\.iweb\.ca\/debian\/ sid testing\n/).without_content(/deb-src/)
    }

    it { is_expected.to contain_apt__pin('my_source').that_comes_before('File[my_source.list]').with({
      'ensure'   => 'present',
      'priority' => '10',
      'origin'   => 'debian.mirror.iweb.ca',
    })
    }

    it { is_expected.to contain_exec("Required packages: 'vim' for my_source").that_comes_before('Exec[apt_update]').that_subscribes_to('File[my_source.list]').with({
      'command'     => '/usr/bin/apt-get -y install vim',
      'logoutput'   => 'on_failure',
      'refreshonly' => true,
      'tries'       => '3',
      'try_sleep'   => '1',
    })
    }

    it { is_expected.to contain_apt__key("Add key: #{GPG_KEY_ID} from Apt::Source my_source").that_comes_before('File[my_source.list]').with({
      'ensure' => 'present',
        'key'  => GPG_KEY_ID,
        'key_server' => 'pgp.mit.edu',
        'key_content' => 'GPG key content',
        'key_source' => 'http://apt.puppetlabs.com/pubkey.gpg',
    })
    }
  end

  context 'trusted_source true' do
    let :facts do
      {
        :lsbdistid       => 'Debian',
        :lsbdistcodename => 'wheezy',
        :osfamily        => 'Debian'
      }
    end
    let :params do
      {
        'include_src'    => false,
        'trusted_source' => true,
      }
    end

    it { is_expected.to contain_file('my_source.list').that_notifies('Exec[apt_update]').with({
      'ensure' => 'present',
      'path'   => '/etc/apt/sources.list.d/my_source.list',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    }).with_content(/# my_source\ndeb \[trusted=yes\]  wheezy main\n/)
    }
  end

  context 'architecture equals x86_64' do
    let :facts do
      {
        :lsbdistid       => 'Debian',
        :lsbdistcodename => 'wheezy',
        :osfamily        => 'Debian'
      }
    end
    let :params do
      {
        'include_deb'  => false,
        'architecture' => 'x86_64',
      }
    end

    it { is_expected.to contain_file('my_source.list').that_notifies('Exec[apt_update]').with({
      'ensure' => 'present',
      'path'   => '/etc/apt/sources.list.d/my_source.list',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    }).with_content(/# my_source\ndeb-src \[arch=x86_64 \]  wheezy main\n/)
    }
  end
 
  context 'ensure => absent' do
    let :facts do
      {
        :lsbdistid       => 'Debian',
        :lsbdistcodename => 'wheezy',
        :osfamily        => 'Debian'
      }
    end
    let :params do
      {
        'ensure' => 'absent',
      }
    end

    it { is_expected.to contain_file('my_source.list').that_notifies('Exec[apt_update]').with({
      'ensure' => 'absent'
    })
    }
  end

  describe 'validation' do
    context 'no release' do
      let :facts do
        {
          :lsbdistid       => 'Debian',
          :osfamily        => 'Debian'
        }
      end

      it do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /lsbdistcodename fact not available: release parameter required/)
      end
    end
  end
end
