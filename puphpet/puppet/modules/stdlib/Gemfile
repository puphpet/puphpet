source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place, fake_version = nil)
  if place =~ /^(git[:@][^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

group :development, :unit_tests do
  gem 'rake', '~> 10.1.0',       :require => false
  gem 'rspec', '~> 3.1.0',       :require => false
  gem 'rspec-puppet',            :require => false
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'puppet-lint',             :require => false
  gem 'pry',                     :require => false
  gem 'simplecov',               :require => false
end

beaker_version = ENV['BEAKER_VERSION']
group :system_tests do
  if beaker_version
   gem 'beaker', *location_for(beaker_version)
  end
  gem 'beaker-rspec',            :require => false
  gem 'serverspec',              :require => false
end

facterversion = ENV['GEM_FACTER_VERSION'] || ENV['FACTER_GEM_VERSION']
if facterversion
  gem 'facter', *location_for(facterversion)
else
  gem 'facter', :require => false
end

puppetversion = ENV['GEM_PUPPET_VERSION'] || ENV['PUPPET_GEM_VERSION']
if puppetversion
  gem 'puppet', *location_for(puppetversion)
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
