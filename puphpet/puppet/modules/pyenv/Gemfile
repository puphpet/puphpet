source 'https://rubygems.org'
if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion
else
  gem 'puppet', '~> 3.5'
end

group :development, :test do
    gem 'puppetlabs_spec_helper' , '~> 0.4.1'
    gem 'puppet-lint'
end

group :debug do
    gem 'pry'
end

group :acceptance do
    gem 'beaker-rspec'
    gem 'serverspec'
end
