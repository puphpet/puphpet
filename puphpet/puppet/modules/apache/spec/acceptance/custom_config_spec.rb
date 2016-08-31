require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache::custom_config define', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'invalid config' do
    it 'should not add the config' do
      pp = <<-EOS
        class { 'apache': }
        apache::custom_config { 'acceptance_test':
          content => 'INVALID',
        }
      EOS

      apply_manifest(pp, :expect_failures => true)
    end

    describe file("#{$confd_dir}/25-acceptance_test.conf") do
      it { is_expected.not_to be_file }
    end
  end

  context 'valid config' do
    it 'should add the config' do
      pp = <<-EOS
        class { 'apache': }
        apache::custom_config { 'acceptance_test':
          content => '# just a comment',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$confd_dir}/25-acceptance_test.conf") do
      it { is_expected.to contain '# just a comment' }
    end
  end

  describe 'custom_config without priority prefix' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        apache::custom_config { 'prefix_test':
          priority => false,
          content => '# just a comment',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$confd_dir}/prefix_test.conf") do
      it { is_expected.to be_file }
    end
  end
end
