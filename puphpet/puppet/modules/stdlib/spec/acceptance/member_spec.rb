#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'member function', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  shared_examples 'item found' do
    it 'should output correctly' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/Notice: output correct/)
      end
    end
  end
  describe 'success' do
    it 'members arrays' do
      pp = <<-EOS
      $a = ['aaa','bbb','ccc']
      $b = 'ccc'
      $c = true
      $o = member($a,$b)
      if $o == $c {
        notify { 'output correct': }
      }
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/Notice: output correct/)
      end
    end
    describe 'members array of integers' do
      it_should_behave_like 'item found' do
        let(:pp) { <<-EOS
      if member( [1,2,3,4], 4 ){
        notify { 'output correct': }
      }
        EOS
        }
      end
    end
    describe 'members of mixed array' do
      it_should_behave_like 'item found' do
        let(:pp) { <<-EOS
      if member( ['a','4',3], 'a' ){
        notify { 'output correct': }
}
        EOS
        }
      end
    end
    it 'members arrays without members'
  end

  describe 'failure' do
    it 'handles improper argument counts'
  end
end
