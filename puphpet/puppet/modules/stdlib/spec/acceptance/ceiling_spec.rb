#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'ceiling function', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  describe 'success' do
    it 'ceilings floats' do
      pp = <<-EOS
      $a = 12.8
      $b = 13
      $o = ceiling($a)
      if $o == $b {
        notify { 'output correct': }
      }
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/Notice: output correct/)
      end
    end
    it 'ceilings integers' do
      pp = <<-EOS
      $a = 7
      $b = 7
      $o = ceiling($a)
      if $o == $b {
        notify { 'output correct': }
      }
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/Notice: output correct/)
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
    it 'handles non-numbers'
  end
end
