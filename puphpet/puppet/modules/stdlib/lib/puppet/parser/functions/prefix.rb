#
# prefix.rb
#

module Puppet::Parser::Functions
  newfunction(:prefix, :type => :rvalue, :doc => <<-EOS
This function applies a prefix to all elements in an array or a hash.

*Examples:*

    prefix(['a','b','c'], 'p')

Will return: ['pa','pb','pc']
    EOS
  ) do |arguments|

    # Technically we support two arguments but only first is mandatory ...
    raise(Puppet::ParseError, "prefix(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    enumerable = arguments[0]

    unless enumerable.is_a?(Array) or enumerable.is_a?(Hash)
      raise Puppet::ParseError, "prefix(): expected first argument to be an Array or a Hash, got #{enumerable.inspect}"
    end

    prefix = arguments[1] if arguments[1]

    if prefix
      unless prefix.is_a?(String)
        raise Puppet::ParseError, "prefix(): expected second argument to be a String, got #{prefix.inspect}"
      end
    end

    if enumerable.is_a?(Array)
      # Turn everything into string same as join would do ...
      result = enumerable.collect do |i|
        i = i.to_s
        prefix ? prefix + i : i
      end
    else
      result = Hash[enumerable.map do |k,v|
        k = k.to_s
        [ prefix ? prefix + k : k, v ]
      end]
    end

    return result
  end
end

# vim: set ts=2 sw=2 et :
