#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'ensure_resource function', :unless => fact('osfamily') =~ /windows/i do
  describe 'success' do
    it 'ensure_resource a package' do
      apply_manifest('package { "rake": ensure => absent, provider => "gem", }')
      pp = <<-EOS
      $a = "rake"
      ensure_resource('package', $a, {'provider' => 'gem'})
      EOS

      apply_manifest(pp, :expect_changes => true)
    end
    it 'ensures a resource already declared'
    it 'takes defaults arguments'
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles non strings'
  end
end
