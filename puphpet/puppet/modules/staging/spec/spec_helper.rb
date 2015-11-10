require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.include PuppetlabsSpec::Files

  c.before :each do
    # Ensure that we don't accidentally cache facts and environment
    # between test cases.
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages

    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key {|k| @old_env[k] = ENV[k]}

    if Gem::Version.new(`puppet --version`) >= Gem::Version.new('3.5')
      Puppet.settings[:strict_variables]=true
    end
    if ENV['PARSER']
      Puppet.settings[:parser]=ENV['PARSER']
    end
  end

  c.after :each do
    PuppetlabsSpec::Files.cleanup
  end
end
