require 'spec_helper_acceptance'

describe 'apt class' do

  context 'reset' do
    it 'fixes the sources.list' do
      shell('cp /etc/apt/sources.list /tmp')
    end
  end

  context 'all the things' do
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'apt':
        always_apt_update    => true,
        disable_keys         => true,
        purge_sources_list   => true,
        purge_sources_list_d => true,
        purge_preferences    => true,
        purge_preferences_d  => true,
        update_timeout       => '400',
        update_tries         => '3',
        sources              => {
          'puppetlabs' => {
            'ensure'     => present,
            'location'   => 'http://apt.puppetlabs.com',
            'repos'      => 'main',
            'key'        => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
            'key_server' => 'pgp.mit.edu',
          }
        },
        fancy_progress       => true,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_failures => true)
    end
    it 'should still work' do
      shell('apt-get update')
      shell('apt-get -y --force-yes upgrade')
    end
  end

  context 'reset' do
    it 'fixes the sources.list' do
      shell('cp /tmp/sources.list /etc/apt')
    end
  end

end
