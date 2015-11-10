#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'getparam function', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  describe 'success' do
    it 'getparam a notify' do
      pp = <<-EOS
      notify { 'rspec':
        message => 'custom rspec message',
      }
      $o = getparam(Notify['rspec'], 'message')
      notice(inline_template('getparam is <%= @o.inspect %>'))
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/getparam is "custom rspec message"/)
      end
    end
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles non strings'
  end
end
