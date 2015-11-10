#
# concat.rb
#

module Puppet::Parser::Functions
  newfunction(:concat, :type => :rvalue, :doc => <<-EOS
Appends the contents of multiple arrays into array 1.

*Example:*

    concat(['1','2','3'],['4','5','6'],['7','8','9'])

Would result in:

  ['1','2','3','4','5','6','7','8','9']
    EOS
  ) do |arguments|

    # Check that more than 2 arguments have been given ...
    raise(Puppet::ParseError, "concat(): Wrong number of arguments " +
      "given (#{arguments.size} for < 2)") if arguments.size < 2

    a = arguments[0]

    # Check that the first parameter is an array
    unless a.is_a?(Array)
      raise(Puppet::ParseError, 'concat(): Requires array to work with')
    end

    result = a
    arguments.shift

    arguments.each do |x|
      result = result + Array(x)
    end

    return result
  end
end

# vim: set ts=2 sw=2 et :
