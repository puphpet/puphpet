#
# upcase.rb
#

module Puppet::Parser::Functions
  newfunction(:upcase, :type => :rvalue, :doc => <<-EOS
Converts a string or an array of strings to uppercase.

*Examples:*

    upcase("abcd")

Will return:

    ASDF
  EOS
  ) do |arguments|

    raise(Puppet::ParseError, "upcase(): Wrong number of arguments " +
                                "given (#{arguments.size} for 1)") if arguments.size != 1

    value = arguments[0]

    unless value.is_a?(Array) || value.is_a?(Hash) || value.respond_to?(:upcase)
      raise(Puppet::ParseError, 'upcase(): Requires an ' +
                                  'array, hash or object that responds to upcase in order to work')
    end

    if value.is_a?(Array)
      # Numbers in Puppet are often string-encoded which is troublesome ...
      result = value.collect { |i| function_upcase([i]) }
    elsif value.is_a?(Hash)
      result = {}
      value.each_pair do |k, v|
        result[function_upcase([k])] = function_upcase([v])
      end
    else
      result = value.upcase
    end

    return result
  end
end

# vim: set ts=2 sw=2 et :
