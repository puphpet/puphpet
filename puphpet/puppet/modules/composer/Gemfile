#ruby=1.9.3@puppet-composer

if ENV.key?('PUPPET_VERSION')
  puppetversion = "= #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['>= 2.7']
end

source 'https://rubygems.org'

gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper'
gem 'rspec-puppet', :github => 'rodjek/rspec-puppet', :ref => '28c29d09e47211b65c0969b55082367a71d2e073'
gem 'rspec', '< 3.0.0'
gem 'mocha'
gem 'puppet-lint'
gem 'hiera'
gem 'hiera-puppet'

group :acceptance do
  gem 'beaker'
  gem 'beaker-rspec'
end
