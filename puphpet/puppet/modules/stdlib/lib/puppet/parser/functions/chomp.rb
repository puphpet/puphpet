#
#  chomp.rb
#

module Puppet::Parser::Functions
  newfunction(:chomp, :type => :rvalue, :doc => <<-'EOS'
    Removes the record separator from the end of a string or an array of
    strings, for example `hello\n` becomes `hello`.
    Requires a single string or array as an input.
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "chomp(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    value = arguments[0]

    unless value.is_a?(Array) || value.is_a?(String)
      raise(Puppet::ParseError, 'chomp(): Requires either ' +
        'array or string to work with')
    end

    if value.is_a?(Array)
      # Numbers in Puppet are often string-encoded which is troublesome ...
      result = value.collect { |i| i.is_a?(String) ? i.chomp : i }
    else
      result = value.chomp
    end

    return result
  end
end

# vim: set ts=2 sw=2 et :
