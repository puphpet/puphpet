#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'fqdn_rotate function', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  describe 'success' do
    let(:facts_d) do
      if fact('is_pe', '--puppet') == "true"
        if fact('osfamily') =~ /windows/i
          if fact('kernelmajversion').to_f < 6.0
            'C:/Documents and Settings/All Users/Application Data/PuppetLabs/facter/facts.d'
          else
            'C:/ProgramData/PuppetLabs/facter/facts.d'
          end
        else
          '/etc/puppetlabs/facter/facts.d'
        end
      else
        '/etc/facter/facts.d'
      end
    end
    after :each do
      shell("if [ -f '#{facts_d}/fqdn.txt' ] ; then rm '#{facts_d}/fqdn.txt' ; fi")
    end
    before :each do
      #No need to create on windows, PE creates by default
      if fact('osfamily') !~ /windows/i
        shell("mkdir -p '#{facts_d}'")
      end
    end
    it 'fqdn_rotates floats' do
      shell("echo fqdn=fakehost.localdomain > '#{facts_d}/fqdn.txt'")
      pp = <<-EOS
      $a = ['a','b','c','d']
      $o = fqdn_rotate($a)
      notice(inline_template('fqdn_rotate is <%= @o.inspect %>'))
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/fqdn_rotate is \["c", "d", "a", "b"\]/)
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
    it 'handles non-numbers'
  end
end
