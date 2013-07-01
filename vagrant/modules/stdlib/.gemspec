#
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "puppetmodule-stdlib"

  s.version = "4.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Puppet Labs"]
  s.date = "2013-04-12"
  s.description = [ 'This Gem format of the stdlib module is intended to make',
                    'it easier for _module authors_ to resolve dependencies',
                    'using a Gemfile when running automated testing jobs like',
                    'Travis or Jenkins.  The recommended best practice for',
                    'installation by end users is to use the `puppet module',
                    'install` command to install stdlib from the [Puppet',
                    'Forge](http://forge.puppetlabs.com/puppetlabs/stdlib).' ].join(' ')
  s.email = "puppet-dev@puppetlabs.com"
  s.executables = []
  s.files = [ 'CHANGELOG', 'CONTRIBUTING.md', 'Gemfile', 'LICENSE', 'Modulefile',
              'README.markdown', 'README_DEVELOPER.markdown', 'RELEASE_PROCESS.markdown',
              'Rakefile', 'spec/spec.opts' ]
  s.files += Dir['lib/**/*.rb'] + Dir['manifests/**/*.pp'] + Dir['tests/**/*.pp'] + Dir['spec/**/*.rb']
  s.homepage = "http://forge.puppetlabs.com/puppetlabs/stdlib"
  s.rdoc_options = ["--title", "Puppet Standard Library Development Gem", "--main", "README.markdown", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "puppetmodule-stdlib"
  s.rubygems_version = "1.8.24"
  s.summary = "This gem provides a way to make the standard library available for other module spec testing tasks."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
