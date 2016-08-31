require 'puppet-lint/tasks/puppet-lint'

# Be extremely pedantic
PuppetLint.configuration.fail_on_warnings = true

# Disable some idiotic checks
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.send('disable_documentation')
