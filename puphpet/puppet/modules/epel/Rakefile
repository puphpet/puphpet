require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'rspec-system/rake_task'

task :default do
  sh %{rake -T}
end

# Disable specific puppet-lint checks
exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]

Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  config.ignore_paths = exclude_paths
  config.fail_on_warnings = true
  config.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
  config.disable_checks = ['80chars', 'class_inherits_from_params_class']
  #config.relative = true
end
PuppetLint.configuration.relative = true

PuppetSyntax.exclude_paths = exclude_paths

desc "Run rspec-puppet and puppet-lint tasks"
task :ci => [
  :syntax,
  :lint,
  :spec,
]
