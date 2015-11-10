#!/usr/bin/env rspec
require 'spec_helper'

describe 'apt::update', :type => :class do
  context 'when apt::always_apt_update is true' do
    #This should completely disable all of this logic. These tests are to guarantee that we don't somehow magically change the behavior.
    let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian' } }
    let (:pre_condition) { "class{'::apt': always_apt_update => true}" }
    it 'should trigger an apt-get update run' do
      #set the apt_update exec's refreshonly attribute to false
      should contain_exec('apt_update').with({'refreshonly' => false })
    end
    ['always','daily','weekly','reluctantly'].each do |update_frequency|
      context "when apt::apt_update_frequency has the value of #{update_frequency}" do
        { 'a recent run' => Time.now.to_i, 'we are due for a run' => 1406660561,'the update-success-stamp file does not exist' => -1 }.each_pair do |desc, factval|
          context "and $::apt_update_last_success indicates #{desc}" do
            let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian', :apt_update_last_success => factval } }
            let (:pre_condition) { "class{'::apt': always_apt_update => true, apt_update_frequency => '#{update_frequency}' }" }
            it 'should trigger an apt-get update run' do
              # set the apt_update exec's refreshonly attribute to false
              should contain_exec('apt_update').with({'refreshonly' => false})
            end
          end
          context 'when $::apt_update_last_success is nil' do
            let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian' } }
            let (:pre_condition) { "class{'::apt': always_apt_update => true, apt_update_frequency => '#{update_frequency}' }" }
            it 'should trigger an apt-get update run' do
              #set the apt_update exec\'s refreshonly attribute to false
              should contain_exec('apt_update').with({'refreshonly' => false})
            end
          end
        end
      end
    end
  end

  context 'when apt::always_apt_update is false' do
    context "and apt::apt_update_frequency has the value of always" do
      { 'a recent run' => Time.now.to_i, 'we are due for a run' => 1406660561,'the update-success-stamp file does not exist' => -1 }.each_pair do |desc, factval|
        context "and $::apt_update_last_success indicates #{desc}" do
          let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian', :apt_update_last_success => factval } }
          let (:pre_condition) { "class{'::apt': always_apt_update => false, apt_update_frequency => 'always' }" }
          it 'should trigger an apt-get update run' do
            #set the apt_update exec's refreshonly attribute to false
            should contain_exec('apt_update').with({'refreshonly' => false})
          end
        end
      end
      context 'when $::apt_update_last_success is nil' do
        let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian' } }
        let (:pre_condition) { "class{ '::apt': always_apt_update => false, apt_update_frequency => 'always' }" }
        it 'should trigger an apt-get update run' do
          #set the apt_update exec\'s refreshonly attribute to false
          should contain_exec('apt_update').with({'refreshonly' => false})
        end
      end
    end
    context "and apt::apt_update_frequency has the value of reluctantly" do
      {'a recent run' => Time.now.to_i, 'we are due for a run' => 1406660561,'the update-success-stamp file does not exist' => -1 }.each_pair do |desc, factval|
        context "and $::apt_update_last_success indicates #{desc}" do
          let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian', :apt_update_last_success => factval} }
          let (:pre_condition) { "class{ '::apt': always_apt_update => false, apt_update_frequency => 'reluctantly' }" }
          it 'should not trigger an apt-get update run' do
            #don't change the apt_update exec's refreshonly attribute. (it should be true)
            should contain_exec('apt_update').with({'refreshonly' => true})
          end
        end
      end
      context 'when $::apt_update_last_success is nil' do
        let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian' } }
        let (:pre_condition) { "class{ '::apt': always_apt_update => false, apt_update_frequency => 'reluctantly' }" }
        it 'should not trigger an apt-get update run' do
          #don't change the apt_update exec's refreshonly attribute. (it should be true)
          should contain_exec('apt_update').with({'refreshonly' => true})
        end
      end
    end
    ['daily','weekly'].each do |update_frequency|
      context "and apt::apt_update_frequency has the value of #{update_frequency}" do
        { 'we are due for a run' => 1406660561,'the update-success-stamp file does not exist' => -1 }.each_pair do |desc, factval|
          context "and $::apt_update_last_success indicates #{desc}" do
            let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian', :apt_update_last_success => factval } }
            let (:pre_condition) { "class{ '::apt': always_apt_update => false, apt_update_frequency => '#{update_frequency}' }" }
            it 'should trigger an apt-get update run' do
              #set the apt_update exec\'s refreshonly attribute to false
              should contain_exec('apt_update').with({'refreshonly' => false})
            end
          end
        end
        context 'when the $::apt_update_last_success fact has a recent value' do
          let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian', :apt_update_last_success => Time.now.to_i } }
          let (:pre_condition) { "class{ '::apt': always_apt_update => false, apt_update_frequency => '#{update_frequency}' }" }
          it 'should not trigger an apt-get update run' do
            #don't change the apt_update exec\'s refreshonly attribute. (it should be true)
            should contain_exec('apt_update').with({'refreshonly' => true})
          end
        end
        context 'when $::apt_update_last_success is nil' do
          let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian' } }
          let (:pre_condition) { "class{ '::apt': always_apt_update => false, apt_update_frequency => '#{update_frequency}' }" }
          it 'should trigger an apt-get update run' do
            #set the apt_update exec\'s refreshonly attribute to false
            should contain_exec('apt_update').with({'refreshonly' => false})
          end
        end
      end
    end
  end
end
