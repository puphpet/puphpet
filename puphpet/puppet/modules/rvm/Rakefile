# This file is managed centrally by modulesync
#   https://github.com/maestrodev/puppet-modulesync

require 'rake/clean'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet_blacksmith/rake_tasks'

CLEAN.include('spec/fixtures/manifests/', 'spec/fixtures/modules/', 'doc', 'pkg')
CLOBBER.include('.tmp', '.librarian')

ENV['STRICT_VARIABLES']='yes' unless Gem::Version.new(Puppet.version) < Gem::Version.new("3.5.0")

task :librarian_spec_prep do
  sh "librarian-puppet install --path=spec/fixtures/modules/"
end
task :spec_prep => :librarian_spec_prep

Rake::Task[:lint].clear # workaround https://github.com/rodjek/puppet-lint/issues/331
PuppetLint.configuration.relative = true # https://github.com/rodjek/puppet-lint/pull/334
PuppetLint::RakeTask.new :lint do |config|
  config.pattern = 'manifests/**/*.pp'
  config.disable_checks = ["80chars", "class_inherits_from_params_class"]
  config.fail_on_warnings = true
  # config.relative = true
end

Blacksmith::RakeTask.new do |t|
  t.build = false # do not build the module nor push it to the Forge, just do the tagging [:clean, :tag, :bump_commit]
end

task :default => [:clean, :validate, :lint, :spec]
