require 'spec_helper'
describe 'apt::pin', :type => :define do
  let(:facts) { { :lsbdistid => 'Debian' } }
  let(:title) { 'my_pin' }

  context 'defaults' do
    it { is_expected.to contain_file("my_pin.pref").with_content(/Explanation: : my_pin\nPackage: \*\nPin: release a=my_pin\nPin-Priority: 0\n/)}
    it { is_expected.to contain_file("my_pin.pref").with({
      'ensure' => 'present',
      'path'   => '/etc/apt/preferences.d/my_pin.pref',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    })
    }
  end

  context 'set version' do
    let :params do
      {
        'packages' => 'vim',
        'version'  => '1',
      }
    end
    it { is_expected.to contain_file("my_pin.pref").with_content(/Explanation: : my_pin\nPackage: vim\nPin: version 1\nPin-Priority: 0\n/)}
    it { is_expected.to contain_file("my_pin.pref").with({
      'ensure' => 'present',
      'path'   => '/etc/apt/preferences.d/my_pin.pref',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    })
    }
  end

  context 'set origin' do
    let :params do
      {
        'packages' => 'vim',
        'origin'   => 'test',
      }
    end
    it { is_expected.to contain_file("my_pin.pref").with_content(/Explanation: : my_pin\nPackage: vim\nPin: origin test\nPin-Priority: 0\n/)}
    it { is_expected.to contain_file("my_pin.pref").with({
      'ensure' => 'present',
      'path'   => '/etc/apt/preferences.d/my_pin.pref',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    })
    }
  end

  context 'not defaults' do
    let :params do
      {
        'explanation'     => 'foo',
        'order'           => 99,
        'release'         => '1',
        'codename'        => 'bar',
        'release_version' => '2',
        'component'       => 'baz',
        'originator'      => 'foobar',
        'label'           => 'foobaz',
        'priority'        => 10,
      }
    end
    it { is_expected.to contain_file("my_pin.pref").with_content(/Explanation: foo\nPackage: \*\nPin: release a=1, n=bar, v=2, c=baz, o=foobar, l=foobaz\nPin-Priority: 10\n/) }
    it { is_expected.to contain_file("my_pin.pref").with({
      'ensure' => 'present',
      'path'   => '/etc/apt/preferences.d/99-my_pin.pref',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    })
    }
  end

  context 'ensure absent' do
    let :params do
      {
        'ensure' => 'absent'
      }
    end
    it { is_expected.to contain_file("my_pin.pref").with({
      'ensure' => 'absent',
    })
    }
  end

  context 'bad characters' do
    let(:title) { 'such  bad && wow!' }
    it { is_expected.to contain_file("such__bad____wow_.pref") }
  end

  describe 'validation' do
    context 'invalid order' do
      let :params do
        {
          'order' => 'foo',
        }
      end
      it do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /Only integers are allowed/)
      end
    end

    context 'packages == * and version' do
      let :params do
        {
          'version' => '1',
        }
      end
      it do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /parameter version cannot be used in general form/)
      end
    end

    context 'packages == * and release and origin' do
      let :params do
        {
          'origin'  => 'test',
          'release' => 'foo',
        }
      end
      it do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /parameters release and origin are mutually exclusive/)
      end
    end

    context 'specific form with release and origin' do
      let :params do
        {
          'release'  => 'foo',
          'origin'   => 'test',
          'packages' => 'vim',
        }
      end
      it do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /parameters release, origin, and version are mutually exclusive/)
      end
    end

    context 'specific form with version and origin' do
      let :params do
        {
          'version'  => '1',
          'origin'   => 'test',
          'packages' => 'vim',
        }
      end
      it do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /parameters release, origin, and version are mutually exclusive/)
      end
    end
  end
end
