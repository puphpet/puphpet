require 'spec_helper'
describe 'apt::backports', :type => :class do

  describe 'when asigning a custom priority to backports' do
    let :facts do
      {
        'lsbdistcodename' => 'Karmic',
        'lsbdistid'       => 'Ubuntu',
        'osfamily'        => 'Debian'
      }
    end

    context 'integer priority' do
      let :params do { :pin_priority => 500 } end

      it { should contain_apt__source('backports').with({
          'location'   => 'http://old-releases.ubuntu.com/ubuntu',
          'release'    => 'karmic-backports',
          'repos'      => 'main universe multiverse restricted',
          'key'        => '630239CC130E1A7FD81A27B140976EAF437D05B5',
          'key_server' => 'pgp.mit.edu',
        })
      }

      it { should contain_apt__pin('backports').with({
          'release'  => 'karmic-backports',
          'priority' => 500,
        })
      }
    end

    context 'invalid priority' do
      let :params do { :pin_priority => 'banana' } end
      it 'should fail' do
        expect { subject }.to raise_error(/must be an integer/)
      end
    end
  end

  describe 'when turning on backports for ubuntu karmic' do

    let :facts do
      {
        'lsbdistcodename' => 'Karmic',
        'lsbdistid'       => 'Ubuntu',
        'osfamily'        => 'Debian'
      }
    end

    it { should contain_apt__source('backports').with({
        'location'   => 'http://old-releases.ubuntu.com/ubuntu',
        'release'    => 'karmic-backports',
        'repos'      => 'main universe multiverse restricted',
        'key'        => '630239CC130E1A7FD81A27B140976EAF437D05B5',
        'key_server' => 'pgp.mit.edu',
      })
    }

    it { should contain_apt__pin('backports').with({
        'release'  => 'karmic-backports',
        'priority' => 200,
      })
    }
  end

  describe "when turning on backports for debian squeeze" do

    let :facts do
      {
        'lsbdistcodename' => 'Squeeze',
        'lsbdistid'       => 'Debian',
        'osfamily'        => 'Debian'
      }
    end

    it { should contain_apt__source('backports').with({
        'location'   => 'http://backports.debian.org/debian-backports',
        'release'    => 'squeeze-backports',
        'repos'      => 'main contrib non-free',
        'key'        => 'A1BD8E9D78F7FE5C3E65D8AF8B48AD6246925553',
        'key_server' => 'pgp.mit.edu',
      })
    }

    it { should contain_apt__pin('backports').with({
        'release'  => 'squeeze-backports',
        'priority' => 200,
      })
    }
  end

  describe "when turning on backports for linux mint debian edition" do

    let :facts do
      {
        'lsbdistcodename' => 'debian',
        'lsbdistid'       => 'LinuxMint',
        'osfamily'        => 'Debian'
      }
    end

    it { should contain_apt__source('backports').with({
        'location'   => 'http://ftp.debian.org/debian/',
        'release'    => 'wheezy-backports',
        'repos'      => 'main contrib non-free',
        'key'        => 'A1BD8E9D78F7FE5C3E65D8AF8B48AD6246925553',
        'key_server' => 'pgp.mit.edu',
      })
    }

    it { should contain_apt__pin('backports').with({
        'release'  => 'wheezy-backports',
        'priority' => 200,
      })
    }
  end

  describe "when turning on backports for linux mint 17 (ubuntu-based)" do

    let :facts do
      {
        'lsbdistcodename' => 'qiana',
        'lsbdistid'       => 'LinuxMint',
        'osfamily'        => 'Debian'
      }
    end

    it { should contain_apt__source('backports').with({
        'location'   => 'http://us.archive.ubuntu.com/ubuntu',
        'release'    => 'trusty-backports',
        'repos'      => 'main universe multiverse restricted',
        'key'        => '630239CC130E1A7FD81A27B140976EAF437D05B5',
        'key_server' => 'pgp.mit.edu',
      })
    }

    it { should contain_apt__pin('backports').with({
        'release'  => 'trusty-backports',
        'priority' => 200,
      })
    }
  end

  describe "when turning on backports for debian squeeze but using your own mirror" do

    let :facts do
      {
        'lsbdistcodename' => 'Squeeze',
        'lsbdistid'       => 'Debian',
        'osfamily'        => 'Debian'
      }
    end

    let :location do
      'http://mirrors.example.com/debian-backports'
    end

    let :params do
      { 'location' => location }
    end

    it { should contain_apt__source('backports').with({
        'location'   => location,
        'release'    => 'squeeze-backports',
        'repos'      => 'main contrib non-free',
        'key'        => 'A1BD8E9D78F7FE5C3E65D8AF8B48AD6246925553',
        'key_server' => 'pgp.mit.edu',
      })
    }

    it { should contain_apt__pin('backports').with({
        'release'  => 'squeeze-backports',
        'priority' => 200,
      })
    }
  end
end
