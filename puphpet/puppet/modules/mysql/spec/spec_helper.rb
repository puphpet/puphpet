require 'puppetlabs_spec_helper/module_spec_helper'
require 'puppet_facts'
include PuppetFacts
RSpec.configure do |c|
  c.formatter = :documentation
end

# The default set of platforms to test again.
ENV['UNIT_TEST_PLATFORMS'] = 'centos-6-x86_64 ubuntu-1404-x86_64'
PLATFORMS = ENV['UNIT_TEST_PLATFORMS'].split(' ')
