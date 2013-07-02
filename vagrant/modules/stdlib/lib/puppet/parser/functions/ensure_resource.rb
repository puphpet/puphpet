# Test whether a given class or definition is defined
require 'puppet/parser/functions'

Puppet::Parser::Functions.newfunction(:ensure_resource,
                                      :type => :statement,
                                      :doc => <<-'ENDOFDOC'
Takes a resource type, title, and a list of attributes that describe a
resource.

    user { 'dan':
      ensure => present,
    }

This example only creates the resource if it does not already exist:

    ensure_resource('user, 'dan', {'ensure' => 'present' })

If the resource already exists but does not match the specified parameters,
this function will attempt to recreate the resource leading to a duplicate
resource definition error.

ENDOFDOC
) do |vals|
  type, title, params = vals
  raise(ArgumentError, 'Must specify a type') unless type
  raise(ArgumentError, 'Must specify a title') unless title
  params ||= {}
  Puppet::Parser::Functions.function(:defined_with_params)
  if function_defined_with_params(["#{type}[#{title}]", params])
    Puppet.debug("Resource #{type}[#{title}] not created b/c it already exists")
  else
    Puppet::Parser::Functions.function(:create_resources)
    function_create_resources([type.capitalize, { title => params }])
  end
end
