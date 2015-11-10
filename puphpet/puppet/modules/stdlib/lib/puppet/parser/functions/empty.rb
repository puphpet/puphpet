#
# empty.rb
#

module Puppet::Parser::Functions
  newfunction(:empty, :type => :rvalue, :doc => <<-EOS
Returns true if the variable is empty.
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "empty(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    value = arguments[0]

    unless value.is_a?(Array) || value.is_a?(Hash) || value.is_a?(String)
      raise(Puppet::ParseError, 'empty(): Requires either ' +
        'array, hash or string to work with')
    end

    result = value.empty?

    return result
  end
end

# vim: set ts=2 sw=2 et :
