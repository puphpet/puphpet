require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.mock_with :rspec do |mock|
    mock.syntax = [:expect, :should]
  end
  c.include PuppetlabsSpec::Files

  c.before :each do
    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key {|k| @old_env[k] = ENV[k]}

    if ENV['STRICT_VARIABLES'] == 'yes'
      Puppet.settings[:strict_variables]=true
    end
  end

  c.after :each do
    PuppetlabsSpec::Files.cleanup
  end
end

# Convenience helper for returning parameters for a type from the
# catalogue.
def param(type, title, param)
  param_value(catalogue, type, title, param)
end

# With rspec-puppet v2.0 this allows coverage checks.
#at_exit { RSpec::Puppet::Coverage.report! }
