require 'spec_helper_acceptance'

describe 'blackfire class' do

  server_id = ENV['BLACKFIRE_SERVER_ID'] || ''
  server_token = ENV['BLACKFIRE_SERVER_TOKEN'] || ''

  describe 'running puppet code' do

    it 'server_id and server_token are not empty' do
      expect(server_id).not_to be_empty
      expect(server_token).not_to be_empty
    end

    it 'we have copied the puppet module' do
      shell("ls #{default['distmoduledir']}/blackfire/metadata.json", {:acceptable_exit_codes => 0})
    end

    it 'should work with no errors' do
      pp = <<-EOS
        class { 'blackfire':
          server_id => '#{server_id}',
          server_token => '#{server_token}',
        }
      EOS

      # Apply twice to ensure no errors the second time.
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stderr).not_to match(/error/i)
      end
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stderr).not_to eq(/error/i)
        expect(r.exit_code).to be_zero
      end
    end

    describe file('/etc/blackfire/agent') do
      it { should be_file }
      its(:content) { should match "server-id=#{server_id}" }
      its(:content) { should match "server-token=#{server_token}" }
    end

    describe service('blackfire-agent') do
      it { should be_enabled }
      it { should be_running }
    end

    it 'CLI is installed' do
      shell("blackfire version", {:acceptable_exit_codes => 0})
    end

    it 'PHP extension is installed' do
      shell("php -m | grep blackfire", {:acceptable_exit_codes => 0})
    end

  end
end
